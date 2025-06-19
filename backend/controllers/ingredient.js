import axios from 'axios';
import qs from 'qs';
import fetch from 'node-fetch';
globalThis.fetch = fetch;

export const detectIngredient = async (req, res) => {
  try {
    const { image } = req.body;

    if (!image || typeof image !== 'string' || !image.startsWith('data:image')) {
      return res.status(400).json({ error: "Please provide a valid base64 image string." });
    }

    const url = process.env.OBJECT_DETECTION_URL;

    const response = await axios.post(
      url,
      qs.stringify({ base64image: image }),
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      }
    );

    return res.json(response.data);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

export const detectIngredientLLM = async (req, res) => {
  try {
    const { image } = req.body;
    if (!image?.startsWith('data:image')) {
      return res.status(400).json({ error: "Provide a valid base64 image string." });
    }

    const apiKey = process.env.OPENROUTER_API_KEY;
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "meta-llama/llama-4-maverick:free",
        messages: [{
          role: "user",
          content: [
            { type: "text", text: "List the ingredients you see in the image. - Use commas to separate each ingredient. - Only include ingredients from the following list: banana, basil, basil_leaves, bay_leaves, beans, bell_pepper_green, bell_pepper_red, bell_pepper_sliced_green, bell_pepper_sliced_red, bell_pepper_sliced_yellow, bell_pepper_yellow, broccoli, brus_capusta, butter, cabbage, cake, carrot, carrot_sliced, cassava, cayliflower, celery, cheese, chicken_breast, chicken_complete, chicken_leg, chicken_thigh, chicken_wing, chili_sauce, cinnamon, cloves, cocoa, corn, cucumber, egg, egg_complete, eggplant, eggplant_complete, eggplant_sliced, fish_circular_orange, fish_circular_white, fish_complete, fish_complete_no_head, fish_fillet_orange, fish_fillet_white, flour, garlic, garlic_clove, ginger, java_turmeric, lasagna, legum, lettuce, lime, lime_complete_green, lime_complete_yellow, lime_leaves, meat_ground, meat_non_ground, milk, mushroom, mushroom_sliced, nut, nutmeg, nuts, onion_garlic, onion_half, onion_orange, onion_purple, onion_white, parsley, pasta, pepper_black, pepper_green, pepper_red, potato, potato_half, potato_no_skin, rice, salad, sausage, shrimp, shrimp_group, spaghetti, spinach, star_anise, steak, sugar, sweet_potato, sweet_soy_sauce, tempeh, tofu, tomato, tomato_half, walnut, watercress, yogurt, zucchini, zucchini_sliced" },
            { type: "image_url", image_url: { url: image } }
          ]
        }]
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      return res.status(response.status).json({ error: errorData });
    }

    const data = await response.json();
    return res.status(200).json({ result: data.choices[0].message.content });
  } catch (error) {
    console.error("Error detecting objects:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
};