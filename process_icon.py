from PIL import Image
import sys

def remove_black_background(input_path, output_path):
    try:
        img = Image.open(input_path)
        img = img.convert("RGBA")
        datas = img.getdata()

        newData = []
        for item in datas:
            # If pixel is black (or very dark), make it transparent
            if item[0] < 10 and item[1] < 10 and item[2] < 10:
                newData.append((0, 0, 0, 0))
            else:
                newData.append(item)

        img.putdata(newData)
        img.save(output_path, "PNG")
        print("Successfully processed image")
    except Exception as e:
        print(f"Error: {e}")
        # If PIL is not installed, we might fail.
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python process_icon.py <input> <output>")
        sys.exit(1)
    
    remove_black_background(sys.argv[1], sys.argv[2])
