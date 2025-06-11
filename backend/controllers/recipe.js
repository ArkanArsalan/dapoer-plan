import fetch from 'node-fetch';
import dotenv from 'dotenv';

dotenv.config();

export const generateRecipe = async (req, res) => {
    try {
        const { ingredients } = req.body;
        let { recipeType } = req.body;

        if (!ingredients || !Array.isArray(ingredients) || ingredients.length === 0) {
            return res.status(400).json({ error: 'Please provide a list of ingredients.' });
        }

        const apiKey = process.env.OPENROUTER_API_KEY;

        if (!recipeType) {
            recipeType = 'general'
        }

        const userPrompt = `Please generate a complete ${recipeType} recipe using the following ingredients: ${ingredients.join(', ')}. Include the dish name, a short description, the list of ingredients, and detailed step-by-step cooking instructions.`;

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
