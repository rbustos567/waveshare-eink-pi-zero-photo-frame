# waveshare-eink-pi-zero-photo-frame

Automated e-Paper photo and info frame for Raspberry Pi Zero W and 7.5" e-Paper Display, powered by dynamic API content, multi-provider stock photo fetching, and robust power/cron orchestration. Automatically renders dynamic information presets (Wikipedia, quotes, trivia) or high-resolution photos (Unsplash, Pexels, Pixabay) with automated log rotation.

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

<img width="3072" height="4096" alt="IMG20260912174707" src="https://github.com/user-attachments/assets/f6178fe5-d90f-4266-ac52-40f9b761cefc" />

---

## Operating System Setup

Before assembling the hardware, prepare the MicroSD card with the required operating system:

1. Download and launch **Raspberry Pi Imager** on your computer.
2. Under **Raspberry Pi Device**, select **Raspberry Pi Zero W**.
3. Under **Operating System**, choose **Raspberry Pi OS Lite (32-bit)** (*A port of Debian with no desktop environment*).
4. Under **Storage**, select your MicroSD card.
5. Click **Next** and configure the OS customization settings (OS Customization / Advanced Options):
   * Enable **SSH** (using password or public key authentication).
   * Set your hostname, username, and password.
   * Configure your **Wi-Fi credentials** (SSID and Password) and country code so the board connects automatically upon booting.
6. Write the image to the MicroSD card and insert it into the Raspberry Pi Zero W.
7. Keep in mind that the first you boot it will take several minutes to see the device in your network and ssh into it. Be very patient.

---

## Software Installation steps
1. Clone this repository
```bash
   git clone https://github.com/rbustos567/waveshare-eink-pi-zero-photo-frame.git
```
2. Install dependency repositories
```bash
   cd ../eink-api-renderer
   chmod +x install.sh
   sudo ./install.sh
   cd ../url-image-to-eink
   chmod +x install.sh
   sudo ./install.sh
```
3. Enable execution permission to scripts
```bash
   cd waveshare-eink-pi-zero-photo-frame
   chmod +x *.sh
```
4. Run installation script
```bash
   ./install.sh
```
5. Populate api_key with you API key in providers.json for image providers that are required, for example: unsplash, pixabay and pexels
```bash
   vim ../multi-provider-url-image-fetcher/providers.json
```

## Usage Examples

The wrapper script `run_on_cron_display_on_eink.sh` acts as the primary execution interface for both manual triggers and automated cron jobs. It handles logging, log rotation (14 days), directory navigation, and argument passing.

## Execution Examples

1. Automatic Selection
Runs the frame in random mode, picking either an information preset or a photo using the default search query:
```bash
   ./run_on_cron_display_on_eink.sh random
```
2. Display Dynamic information
Forces the frame to query the API renderer and display textual info/facts:
```bash
   ./run_on_cron_display_on_eink.sh info
```
3. Display Photo with Default Query
Forces photo mode using DEFAULT_SEARCH_QUERY (e.g., "street photography") defined in frame.conf:
```bash
   ./run_on_cron_display_on_eink.sh photo
```
4. Display Photo with Custom Query
Overrides the default search query with a custom phrase (enclosed in double quotes if it contains spaces):
```bash
   ./run_on_cron_display_on_eink.sh photo "minimalist architecture"
```
5. Omit Mode Parameter
If no arguments are provided, the script automatically defaults to random:
```bash
   ./run_on_cron_display_on_eink.sh
```
Logs and Outputs
All console outputs, timestamps, and error traces are automatically directed to daily log files inside the logs/ directory:
```bash
   # View today's execution logs in real time
   tail -f logs/run_$(date +%Y%m%d).log
```
## Project Gallery

<img width="4096" height="3072" alt="IMG20260912121156" src="https://github.com/user-attachments/assets/2805f0bf-7b78-4033-917f-7a08f2bf3131" />
<img width="3072" height="4096" alt="IMG20260912121205" src="https://github.com/user-attachments/assets/20fbdb56-738a-40d6-8147-2f024b94334f" />

