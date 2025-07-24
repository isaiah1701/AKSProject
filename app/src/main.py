from fastapi import FastAPI, UploadFile, File, HTTPException, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
import os
from typing import List, Dict, Any
import logging

from src.model import get_classifier
from src.utils import preprocess_image, validate_image_file

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Image Classification API",
    description="Image classification using MobileNetV2 deep learning model",
    version="1.0.0"
)

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.on_event("startup")
async def startup_event():
    """Load the model on startup"""
    logger.info("Loading MobileNetV2 model...")
    get_classifier()
    logger.info("Model loaded successfully")

@app.get("/", response_class=HTMLResponse)
async def root():
    """Serve the main HTML page"""
    try:
        with open("static/index.html", "r") as f:
            html_content = f.read()
        return HTMLResponse(content=html_content)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="HTML file not found")

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Classify an uploaded image using MobileNetV2
    
    Args:
        file: Uploaded image file
        
    Returns:
        Dictionary containing predictions with labels and confidence scores
    """
    try:
        # Validate file type
        if not validate_image_file(file.filename):
            raise HTTPException(
                status_code=400, 
                detail="Invalid file type. Please upload a valid image file (JPG, PNG, etc.)"
            )
        
        # Read image bytes
        image_bytes = await file.read()
        
        if len(image_bytes) == 0:
            raise HTTPException(status_code=400, detail="Empty file uploaded")
        
        # Preprocess image
        logger.info(f"Processing image: {file.filename}")
        preprocessed_image = preprocess_image(image_bytes)
        
        # Get classifier and make prediction
        classifier = get_classifier()
        predictions = classifier.predict(preprocessed_image)
        
        # Format results
        formatted_predictions = []
        for class_id, class_name, confidence in predictions:
            formatted_predictions.append({
                "class_id": class_id,
                "label": class_name.replace("_", " ").title(),
                "confidence": confidence
            })
        
        logger.info(f"Classification complete for {file.filename}")
        
        return {
            "filename": file.filename,
            "predictions": formatted_predictions
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing image {file.filename}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "model": "MobileNetV2"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", "8000"))
    uvicorn.run(app, host="0.0.0.0", port=port)
