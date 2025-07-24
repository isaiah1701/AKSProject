# Image Classification FastAPI Application

A FastAPI application for image classification using TensorFlow's MobileNetV2 pretrained model.

## Features

- **Web Interface**: Simple HTML upload form with drag-and-drop functionality
- **Image Classification**: Uses MobileNetV2 pretrained on ImageNet
- **Real-time Results**: Displays top 5 predictions with confidence scores
- **Docker Support**: Containerized application ready for deployment
- **Health Checks**: Built-in health monitoring endpoint

## Project Structure

```
app/
├── src/
│   ├── main.py          # FastAPI application and endpoints
│   ├── model.py         # MobileNetV2 model wrapper
│   └── utils.py         # Image preprocessing utilities
├── static/
│   └── index.html       # Web interface
├── Dockerfile           # Container configuration
├── requirements.txt     # Python dependencies
└── README.md           # This file
```

## Quick Start

### Local Development

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the application:**
   ```bash
   cd src
   python main.py
   ```

3. **Access the application:**
   Open http://localhost:80 in your browser

### Docker Deployment

1. **Build the image:**
   ```bash
   docker build -t image-classifier .
   ```

2. **Run the container:**
   ```bash
   docker run -p 80:80 image-classifier
   ```

## API Endpoints

- `GET /` - Web interface for image upload
- `POST /predict` - Image classification endpoint
- `GET /health` - Health check endpoint

### Image Classification API

**Endpoint:** `POST /predict`

**Request:**
- Form data with `file` field containing image file
- Supported formats: JPG, PNG, BMP, GIF, TIFF, WebP

**Response:**
```json
{
  "filename": "example.jpg",
  "predictions": [
    {
      "class_id": "n02123045",
      "label": "Tabby Cat",
      "confidence": 0.8234
    },
    ...
  ]
}
```

## Model Details

- **Architecture**: MobileNetV2
- **Pretrained on**: ImageNet dataset
- **Input size**: 224x224 RGB images
- **Output**: 1000 ImageNet classes
- **Top-K predictions**: 5

## Development

### Adding New Features

1. **Model changes**: Modify `src/model.py`
2. **Preprocessing**: Update `src/utils.py`
3. **API endpoints**: Add to `src/main.py`
4. **Frontend**: Update `static/index.html`

### Testing

```bash
# Test the health endpoint
curl http://localhost:80/health

# Test image classification
curl -X POST -F "file=@test_image.jpg" http://localhost:80/predict
```

## Deployment Considerations

- **Memory**: TensorFlow models require significant RAM (~1-2GB)
- **CPU**: Inference time varies with CPU power
- **Storage**: Model weights are downloaded on first run
- **Scaling**: Consider model caching for multiple instances

## Troubleshooting

### Common Issues

1. **Out of Memory**: Reduce batch size or use smaller model
2. **Slow inference**: Ensure adequate CPU resources
3. **Import errors**: Verify all dependencies are installed
4. **File upload fails**: Check file size limits and formats

### Logs

Application logs include:
- Model loading status
- Image processing information
- Error details for debugging

## License

This project uses open-source libraries and pretrained models:
- FastAPI: MIT License
- TensorFlow: Apache 2.0 License
- MobileNetV2: Apache 2.0 License
# Pipeline trigger - Thu Jul 24 15:34:18 BST 2025
# Pipeline trigger - Thu Jul 24 15:45:17 BST 2025
# Pipeline Test - 2025-07-24 15:54:51
# CI/CD Test - 2025-07-24 16:15:36
