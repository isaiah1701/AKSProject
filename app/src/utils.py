from PIL import Image
import numpy as np
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
import io
from typing import Union

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Preprocess image for MobileNetV2 model
    
    Args:
        image_bytes: Raw image bytes from uploaded file
        
    Returns:
        Preprocessed image array ready for model input
    """
    # Open image from bytes
    image = Image.open(io.BytesIO(image_bytes))
    
    # Convert to RGB if necessary (handles RGBA, grayscale, etc.)
    if image.mode != 'RGB':
        image = image.convert('RGB')
    
    # Resize to 224x224 (MobileNetV2 input size)
    image = image.resize((224, 224), Image.Resampling.LANCZOS)
    
    # Convert to numpy array
    image_array = np.array(image)
    
    # Add batch dimension
    image_array = np.expand_dims(image_array, axis=0)
    
    # Preprocess for MobileNetV2 (applies normalization)
    preprocessed_image = preprocess_input(image_array)
    
    return preprocessed_image

def validate_image_file(filename: str) -> bool:
    """
    Validate if uploaded file is a supported image format
    
    Args:
        filename: Name of the uploaded file
        
    Returns:
        True if file extension is supported, False otherwise
    """
    supported_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tiff', '.webp'}
    file_extension = filename.lower().split('.')[-1]
    return f'.{file_extension}' in supported_extensions
