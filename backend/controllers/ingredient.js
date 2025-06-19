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

    const detections = response.data.detections || [];

    const ingredients = detections
      .filter(det => det.confidence > 0.7)
      .map(det => det.class_name)
      .filter((value, index, self) => self.indexOf(value) === index);

    const formatted = ingredients.map(name =>
      name.charAt(0).toUpperCase() + name.slice(1)
    );

    return res.json({ result: formatted.join(", ") });
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
        model: "google/gemma-3-27b-it:free",
        messages: [{
          role: "user",
          content: [
            { type: "text", text: "List edible ingredients in the image, use comma to seperate each ingredient, just ingredient dont add any other word, other than edible ingredient no result" },
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