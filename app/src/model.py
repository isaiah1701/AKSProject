import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input, decode_predictions
import numpy as np
from typing import List, Tuple

class ImageClassifier:
    def __init__(self):
        """Initialize the MobileNetV2 model"""
        self.model = MobileNetV2(weights='imagenet', include_top=True)
        print("MobileNetV2 model loaded successfully")
    
    def predict(self, preprocessed_image: np.ndarray) -> List[Tuple[str, str, float]]:
        """
        Make predictions on preprocessed image
        
        Args:
            preprocessed_image: Preprocessed image array ready for model input
            
        Returns:
            List of tuples containing (class_id, class_name, confidence_score)
        """
        # Make prediction
        predictions = self.model.predict(preprocessed_image)
        
        # Decode predictions to get top 5 results
        decoded_predictions = decode_predictions(predictions, top=5)[0]
        
        # Format results as list of tuples
        results = []
        for class_id, class_name, confidence in decoded_predictions:
            results.append((class_id, class_name, float(confidence)))
        
        return results

# Global model instance
classifier = None

def get_classifier():
    """Get or create the global classifier instance"""
    global classifier
    if classifier is None:
        classifier = ImageClassifier()
    return classifier
