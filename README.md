# waveshare-eink-pi-zero-photo-frame

Automated scheduled e-Paper photo frame pipeline for Raspberry Pi Zero and Waveshare B&W displays, featuring multi-provider API support (Unsplash, Pixabay, Pexels, Quotes, Wikipedia, etc) and cron orchestration. 

## Features

- **Multi-Provider API Integration:** Randomly rotates queries across Unsplash, Pixabay, Pexels, Wikipedia, Quotes, etc endpoints using a dynamic provider map (providers.json and presets.json).
- **Automated Cron Orchestration:** Designed for hands-free execution with timestamped logging, environment variable loading, and automatic directory context switching.
- **Hardware-Tailored Rendering:** Converts, scales, and dithers high-resolution web photographs specifically for monochrome/B&W Waveshare e-Paper displays.
- **Strict Path & Environment Isolation:** Utilizes absolute path mapping (script.conf and info_script.conf) and non-interactive shell validation to ensure reliable operation under cron or systemd.
- **Secure Credential Handling:** Isolates sensitive API access tokens using a local .env architecture ignored by version control.
- **Modular Pipeline Architecture:** Clean separation of concerns between API data retrieval (Python CLI), orchestration/downloading (Bash wrappers), and hardware rendering.

---

## Hardware Requirements

### Materials & Hardware
* **Raspberry Pi Zero W** (with GPIO headers soldered)
* **Waveshare 7.5" e-Paper Display (800×480 resolution)** with HAT / Driver Board for Raspberry Pi
* **MicroSD Card** (16 GB minimum recommended, Class 10 / UHS-I)
* **6" × 8" Photo Frame**
* **Thick White Cardstock / Mat Board** (approx. 30 cm × 30 cm)
* **Power Supply for Raspberry Pi** (Input: 100–240V AC 50/60Hz, Output: 5V / 4A DC)
* **M2.5 Nylon Standoffs & Screws Kit** (using M2.5 nylon hardware):
  * 8 × M2.5 Screws
  * 4 × M2.5 (6mm + 6mm) Male-Female Standoffs
  * 4 × M2.5 (8mm) Female-Female Standoffs

### Tools Required
* **Precision Screwdriver** (Crosshead/Phillips)
* **18mm Utility Knife / Cutter**
* **30cm Plastic Ruler**
* **Pencil**
* **Pliers**
* **Hammer**
* **Nail or Pin** (for precision hole punching)

---

## Hardware Assembly & Frame Mounting

This assembly process is based on the design approach demonstrated in [this tutorial video](https://www.youtube.com/watch?v=7CdTn6JiLe0), customized for a 6" × 8" photo frame using M2.5 nylon standoff hardware.

### 1. e-Paper Display & Raspberry Pi Wiring
Connect the Waveshare 7.5" e-Paper HAT to the Raspberry Pi Zero W GPIO pins using the provided 8-pin ribbon cable assembly according to the standard SPI interface mapping:

| e-Paper HAT Wire | Raspberry Pi Zero W GPIO Pin | Physical Pin No. | Description |
| :--- | :--- | :--- | :--- |
| **VCC** | 3.3V | Pin 1 | Power Input (3.3V) |
| **GND** | GND | Pin 6 | Ground |
| **DIN (MOSI)** | GPIO 10 (SPI0_MOSI) | Pin 19 | SPI Master Out Slave In |
| **CLK (SCK)** | GPIO 11 (SPI0_SCLK) | Pin 23 | SPI Clock |
| **CS** | GPIO 8 (SPI0_CE0) | Pin 24 | SPI Chip Select |
| **DC** | GPIO 25 | Pin 22 | Data / Command Control |
| **RST** | GPIO 17 | Pin 11 | Hardware Reset |
| **BUSY** | GPIO 24 | Pin 18 | Busy Status |

---

### 2. Step-by-Step Assembly Instructions

#### Step 1: Matting & Bezel Preparation
1. **Measure and Cut:** Using the 30 cm plastic ruler and pencil, measure the inner dimensions of the 6" × 8" photo frame on the thick white cardstock.
2. **Cut Frame Mat:** Carefully cut out the outer mat board using the 18mm utility knife.
3. **Display Window:** Measure the active viewing area of the 7.5" Waveshare display (approx. 163mm × 98mm) centered on the cardstock, and cut out the window opening using the cutter and ruler for clean, straight edges.

#### Step 2: Mounting Hardware & Hole Punching
1. **Mark Standoff Locations:** Align the Waveshare HAT driver board and Raspberry Pi Zero W on the frame backing or custom mounting plate.
2. **Precision Punching:** Use the pin/nail and hammer to make precise guide holes for the M2.5 nylon standoffs.
3. **Assemble Nylon Standoffs:**
   * Attach the 4 × M2.5 (8mm) Female-Female standoffs and secure them with M2.5 screws using the screwdriver.
   * Secure the Raspberry Pi Zero W elevated above the HAT using the 4 × M2.5 (6mm + 6mm) Male-Female standoffs to ensure adequate airflow and prevent electrical shorting.
   * Tighten firmly with pliers and screwdriver without over-tightening.

#### Step 3: Frame Assembly & Enclosure
1. **Insert Display & Mat:** Place the cut white cardstock matting into the 6" × 8" picture frame glass, followed by the 7.5" Waveshare e-Paper screen facing forward.
2. **Secure Electronics:** Place the mounted Raspberry Pi Zero W, Waveshare HAT, and standoff assembly directly behind the display.
3. **Route Power:** Route the micro-USB power cord from the 5V/4A power supply through the back opening of the frame.
4. **Close Backing:** Secure the frame backing tabs into place. Ensure all components are securely fitted without applying excessive pressure to the glass or e-Paper display panel.

## Software Installation steps
1. Clone dependency repositories
```bash
   git clone https://github.com/rbustos567/multi-provider-url-image-fetcher.git
   git clone https://github.com/rbustos567/url-image-to-eink.git
   git clone https://github.com/rbustos567/eink-api-renderer.git
```
2. Clone this repository
```bash
   git clone https://github.com/rbustos567/waveshare-eink-pi-zero-photo-frame.git
   cd waveshare-eink-pi-zero-photo-frame
```
3. Configure setting variables in script.conf and info_script.conf
```bash
   vim script.conf
   vim info_script.conf
```
4. Set API Keys for Photo Sites in .env
```bash
   vim .env
```
5. Set execution permission to all bash scripts
```bash
   chmod +x display_on_eink_random_photo_from_url.sh
   chmod +x run_on_cron_display_photo_eink.sh
   chmod +x display_on_eink_random_info_from_api_url.sh
   chmod +x run_on_cron_display_info_eink.sh
```
6. Copy lines from contab.txt to crontab
```bash
   crontab -e
   # Example: Update e-ink screen with random photo every 2 hrs from 9 AM to 9 PM
   0 9-21/2 * * * /home/pi/projects/display-on-eink-random-photo/run_on_cron_display_photo_eink.sh
```
