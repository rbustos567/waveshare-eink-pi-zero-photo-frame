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
* **Raspberry Pi Zero W** (with female 40-pin GPIO header soldered)
* **Waveshare 7.5" e-Paper Display (800×480 resolution)** with **e-Paper Driver HAT (Rev2.3)**
* **MicroSD Card** (16 GB minimum recommended, Class 10 / UHS-I)
* **6" × 8" Photo Frame** (with wooden/MDF back panel and stand)
* **Thick White Cardstock / Mat Board** (approx. 30 cm × 30 cm)
* **Power Supply for Raspberry Pi** (Input: 100–240V AC 50/60Hz, Output: 5V / 4A DC via Micro-USB)
* **M2.5 Nylon Standoffs & Screws Kit** (EVGATSAUTO or equivalent):
  * 8 × M2.5 Screws
  * 4 × M2.5 (6mm + 6mm) Male-Female Hex Standoffs
  * 4 × M2.5 (8mm) Female-Female Hex Standoffs

### Tools Required
* **Precision Screwdriver** (Crosshead / Phillips)
* **18mm Utility Knife / Cutter**
* **Plastic Ruler** (30 cm)
* **Pencil**
* **Pliers**
* **Hammer**
* **Nail or Pin** (used as a punch tool to pre-drill guide holes in the frame backboard)

---

## Hardware Assembly & Frame Mounting

This assembly guide is based on the design methodology from [this video tutorial](https://www.youtube.com/watch?v=7CdTn6JiLe0), customized for a 6" × 8" photo frame using M2.5 nylon standoff hardware and direct GPIO stacking.

### 1. e-Paper HAT Hardware Configuration
Before mounting the board, verify that the DIP switches on the **Waveshare e-Paper Driver HAT (Rev2.3)** are set correctly for the 7.5" e-Paper display:

* **Display Config Switch:** Set to **B** (`0.47R`)
* **Interface Config Switch:** Set to **0** (`4-line SPI`)

---

### 2. Step-by-Step Assembly Instructions

#### Step 1: Matting & Display Window
1. Using the 30 cm plastic ruler and pencil, measure the inner dimensions of the 6" × 8" frame glass on the thick white cardstock.
2. Cut the cardstock to size using the 18mm utility knife.
3. Measure and center the active viewing area of the 7.5" Waveshare display (approx. 163mm × 98mm) on the cardstock, then cut out the window opening for a clean frame mat.

#### Step 2: Backboard Preparation & FPC Extension Mounting
1. Position the e-Paper display and cardstock mat behind the frame glass.
2. Carefully route the display's ribbon cable (FPC) through a small cutout in the frame's MDF backboard.
3. Secure the small FPC connector board onto the outer side of the MDF backboard using tape, ensuring it stays firmly in place.
4. With the FPC board taped down, connect the display's ribbon cable to one side and the longer white flat flexible cable (FFC) to the other side.

<img width="4096" height="3072" alt="IMG20260912174752" src="https://github.com/user-attachments/assets/ba13d943-92e1-470f-afa6-4738168bfd62" />

#### Step 3: Stacking & Mounting the Raspberry Pi & HAT
1. **Mark Hole Locations:** Place the Raspberry Pi Zero W and Waveshare HAT on the backboard to mark the 4 mounting holes with a pencil.
2. **Punch Guide Holes:** Using the pin/nail and hammer, punch small pilot holes through the MDF backboard.
3. **Assemble the Standoffs & Boards:**
   * Insert 4 × M2.5 screws from the inside of the backboard through the pre-punched holes.
   * Screw the **4 × M2.5 (8mm) Female-Female nylon standoffs** onto the backboard.
   * Place the **Raspberry Pi Zero W** over the 8mm standoffs.
   * Thread the **4 × M2.5 (6mm + 6mm) Male-Female standoffs** through the Raspberry Pi mounting holes into the lower standoffs to lock the Pi in place.
   * Align and plug the **Waveshare e-Paper Driver HAT** directly onto the Raspberry Pi Zero W 40-pin GPIO header.
   * Secure the HAT on top using 4 × M2.5 screws and tighten gently using pliers and precision screwdriver.

<img width="4096" height="3072" alt="IMG20260912174725" src="https://github.com/user-attachments/assets/c198e806-ffce-43f3-bcf4-d96dea5ba670" />

#### Step 4: Interconnections & Power
1. Connect the white flat flexible cable (FFC) from the FPC extension board directly to the main ribbon connector on the Waveshare HAT.
2. Plug the Micro-USB power cable from the 5V/4A power supply into the power port of the Raspberry Pi Zero W.
3. Re-attach the backboard tabs onto the frame to lock everything securely.

---

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
