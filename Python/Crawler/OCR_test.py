from PIL import Image
import pytesseract

imageObject = Image.open('D:/DaemonCode.jpg')
print(imageObject)
print(pytesseract.image_to_string(imageObject))