from flask import Flask, send_file, request
from flask_restx import Api, Resource
import barcode
from barcode.writer import ImageWriter
import io

app = Flask(__name__)
api = Api(app)

# Get all available barcode types supported by python-barcode
BARCODE_TYPES = barcode.PROVIDED_BARCODES  # List of available barcode types
print(BARCODE_TYPES)

class BarcodeResource(Resource):
    def get(self):
        # Get 'value' and 'type' from query parameters
        value = request.args.get('value', '123456789012')  # Default value
        barcode_type = request.args.get('type', 'ean13').lower()  # Default to EAN-13

        # Check if the requested barcode type is valid
        if barcode_type not in BARCODE_TYPES:
            return {'message': f'Invalid barcode type. Available types: {", ".join(BARCODE_TYPES)}'}, 400

        # Generate barcode dynamically
        barcode_class = barcode.get_barcode_class(barcode_type)

        try:
            # Create barcode instance
            barcode_instance = barcode_class(value, writer=ImageWriter())

            # Save the barcode image to a BytesIO object
            img_io = io.BytesIO()
            barcode_instance.write(img_io)
            img_io.seek(0)

            # Return the image as a response
            return send_file(img_io, mimetype='image/png')

        except Exception as e:
            return {'message': f'Error generating barcode: {str(e)}'}, 400

# Add the resource to the API
api.add_resource(BarcodeResource, '/data')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=12138, debug=True)