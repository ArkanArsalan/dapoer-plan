from flask import Flask, request, jsonify
import base64
import io
from PIL import Image
import numpy as np
from ultralytics import YOLO

app = Flask(__name__)
model = YOLO("best.pt")

def read_base64_image(base64_string):
    # Strip the prefix if present
    if base64_string.startswith("data:image"):
        base64_string = base64_string.split(",")[1]

    image_data = base64.b64decode(base64_string)
    image = Image.open(io.BytesIO(image_data)).convert("RGB")
    return np.array(image)


@app.route('/detect/ingredient', methods=['POST'])
def detect_ingredient():
    base64_image = request.form.get('base64image')
    if not base64_image:
        return jsonify({'error': 'Missing image in form data'}), 400
    
    try:
        image = read_base64_image(base64_image)

        results = model(image)[0]
        detections = []
        for box in results.boxes.data.tolist():
            x1, y1, x2, y2, score, cls = box
            detections.append({
                'class_id': int(cls),
                'class_name': results.names[int(cls)],
                'confidence': float(score),
                'bbox': [x1, y1, x2, y2]
            })

        return jsonify({'detections': detections})

    except Exception as e:
        return jsonify({'error': str(e)}), 500