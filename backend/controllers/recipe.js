import fetch from 'node-fetch';
import dotenv from 'dotenv';
import { recipes } from '../utils/csvRecipeLoader.js';

dotenv.config();

export const generateRecipe = async (req, res) => {
    try {
        const { ingredients } = req.body;
        let { recipeType } = req.body;

        if (!ingredients) {
            return res.status(400).json({ error: 'Please provide a list of ingredients.' });
        }

        const apiKey = process.env.OPENROUTER_API_KEY;

        if (!recipeType) {
            recipeType = 'general'
        }

        const userPrompt = `Buatkan 1 resep masakan khas ${recipeType} berdasarkan bahan-bahan berikut (tidak harus semua digunakan, pilih yang cocok dan realistis untuk dimasak bersama): ${ingredients}
                            Jika sebelmum ini tidak ada ingredient terdeteksi bukan bahan makanan seperti none atau strip, maka jangan outputkan apapun
                            Output HARUS ditulis dalam format *Markdown* yang STRUKTURNYA TIDAK BOLEH BERUBAH. Gunakan struktur seperti ini:

                            ## Judul Resep
                            [Nama resep masakan khas Indonesia]

                            ### Bahan-bahan
                            - [Bahan 1]
                            - [Bahan 2]
                            - ...

                            ### Cara Memasak
                            1. [Langkah 1]
                            2. [Langkah 2]
                            3. ...

                            ### Informasi Nutrisi (Perkiraan per Porsi)
                            - Kalori: [jumlah] kcal  
                            - Protein: [jumlah] g  
                            - Lemak: [jumlah] g  
                            - Karbohidrat: [jumlah] g

                            Catatan:
                            - TIDAK BOLEH ada teks tambahan di luar struktur itu.
                            - JANGAN memberikan pengantar, penjelasan, atau penutup.
                            -
                            `

        const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${apiKey}`,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                model: "deepseek/deepseek-r1-0528-qwen3-8b:free",
                messages: [
                    {
                        role: "user",
                        content: userPrompt
                    }
                ]
            })
        });

        if (!response.ok) {
            const errorData = await response.json();
            return res.status(response.status).json({ error: errorData });
        }

        const data = await response.json();
        return res.status(200).json({ result: data.choices[0].message.content });

    } catch (error) {
        console.error("Error generating recipe:", error);
        return res.status(500).json({ error: "Internal server error" });
    }
};

export const getRandomRecipe = (req, res) => {
    try {
        const { limit } = req.query;
        const numRecipes = parseInt(limit, 10) || 1;

        if (!recipes || recipes.length === 0) {
            return res.status(503).json({ message: "Recipes not loaded yet" });
        }

        const maxLimit = Math.min(numRecipes, recipes.length);

        // Shuffle recipes using Fisher-Yates algorithm
        const shuffled = [...recipes];
        for (let i = shuffled.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
        }

        const randomRecipes = shuffled.slice(0, maxLimit);

        res.json({
            success: true,
            data: randomRecipes
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
};

export const getRecipes = (req, res) => {
    try {
        let { page, limit, keyword } = req.query;

        page = parseInt(page) || 1;
        limit = parseInt(limit) || 1;
        const offset = (page - 1) * limit;

        if (!recipes || recipes.length === 0) {
            return res.status(503).json({ message: "Recipes not loaded yet" });
        }

        let filteredRecipes = recipes;
        if (keyword) {
            const lowerKeyword = keyword.toLowerCase();
            filteredRecipes = recipes.filter(recipe =>
                recipe.title?.toLowerCase().includes(lowerKeyword) ||
                recipe.description?.toLowerCase().includes(lowerKeyword)
            );
        }

        const pagedRecipes = filteredRecipes.slice(offset, offset + limit);

        res.json({
            success: true,
            data: pagedRecipes,
            pagination: {
                currentPage: page,
                totalItems: filteredRecipes.length,
                totalPages: Math.ceil(filteredRecipes.length / limit)
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};


