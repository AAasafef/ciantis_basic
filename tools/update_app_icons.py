from pathlib import Path
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(r"C:\Users\shave\Downloads\ChatGPT Image Jun 30, 2026, 11_26_04 AM.png")


def icon_source() -> Image.Image:
    image = Image.open(SOURCE).convert("RGB")
    # Tight crop around the rounded CIANTIS tile, removing the outer presentation background.
    crop = image.crop((70, 70, 1186, 1186))
    return crop.resize((1024, 1024), Image.Resampling.LANCZOS)


def save_png(image: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    resized = image.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(path, "PNG", optimize=True)


def main() -> None:
    base = icon_source()

    android = {
        "mipmap-mdpi/ic_launcher.png": 48,
        "mipmap-hdpi/ic_launcher.png": 72,
        "mipmap-xhdpi/ic_launcher.png": 96,
        "mipmap-xxhdpi/ic_launcher.png": 144,
        "mipmap-xxxhdpi/ic_launcher.png": 192,
    }
    for rel_path, size in android.items():
        save_png(base, ROOT / "android/app/src/main/res" / rel_path, size)

    ios = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for filename, size in ios.items():
        save_png(base, ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset" / filename, size)

    macos = {
        "app_icon_16.png": 16,
        "app_icon_32.png": 32,
        "app_icon_64.png": 64,
        "app_icon_128.png": 128,
        "app_icon_256.png": 256,
        "app_icon_512.png": 512,
        "app_icon_1024.png": 1024,
    }
    for filename, size in macos.items():
        save_png(base, ROOT / "macos/Runner/Assets.xcassets/AppIcon.appiconset" / filename, size)

    web = {
        "favicon.png": 32,
        "icons/Icon-192.png": 192,
        "icons/Icon-512.png": 512,
        "icons/Icon-maskable-192.png": 192,
        "icons/Icon-maskable-512.png": 512,
    }
    for rel_path, size in web.items():
        save_png(base, ROOT / "web" / rel_path, size)

    ico_sizes = [16, 32, 48, 64, 128, 256]
    ico_images = [base.resize((size, size), Image.Resampling.LANCZOS) for size in ico_sizes]
    ico_images[-1].save(
        ROOT / "windows/runner/resources/app_icon.ico",
        sizes=[(size, size) for size in ico_sizes],
    )


if __name__ == "__main__":
    main()
