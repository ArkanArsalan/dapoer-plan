import axios from 'axios';
import qs from 'qs';

export const detectIngredient = async (req, res) => {
    try {
        const { base64image } = req.body;

        if (!base64image) {
            return res.status(400).json({ error: 'Image (base64) is required' });
        }

        const url = process.env.OBJECT_DETECTION_URL;

        const response = await axios.post(
            url,
            qs.stringify({ base64image: base64image }),
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