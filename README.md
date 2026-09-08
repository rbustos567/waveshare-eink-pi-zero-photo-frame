# waveshare-eink-pi-zero-photo-frame

Automated scheduled e-Paper photo frame pipeline for Raspberry Pi Zero and Waveshare B&W displays, featuring multi-provider API support (Unsplash, Pixabay, Pexels) and cron orchestration. 

## Features

- **Multi-Provider API Integration:** Randomly rotates queries across Unsplash, Pixabay, and Pexels endpoints using a dynamic provider map (providers.json).
- **Automated Cron Orchestration:** Designed for hands-free execution with timestamped logging, environment variable loading, and automatic directory context switching.
- **Hardware-Tailored Rendering:** Converts, scales, and dithers high-resolution web photographs specifically for monochrome/B&W Waveshare e-Paper displays.
- **Strict Path & Environment Isolation:** Utilizes absolute path mapping (script.conf) and non-interactive shell validation to ensure reliable operation under cron or systemd.
- **Secure Credential Handling:** Isolates sensitive API access tokens using a local .env architecture ignored by version control.
- **Modular Pipeline Architecture:** Clean separation of concerns between API data retrieval (Python CLI), orchestration/downloading (Bash wrappers), and hardware rendering.

---

## Installation steps
1. Clone dependency repositories
```bash
   git clone https://github.com/rbustos567/multi-provider-url-image-fetcher.git
   git clone https://github.com/rbustos567/url-image-to-eink.git
```
2. Clone this repository
```bash
   git clone https://github.com/rbustos567/waveshare-eink-pi-zero-photo-frame.git
   cd waveshare-eink-pi-zero-photo-frame
```
3. Configure variables in script.conf
```bash
   vim script.conf
```
4. Set API Keys for Photo Sites in .env
```bash
   vim .env
```
5. Set execution permission to all bash scripts
```bash
   chmod +x display_on_eink_random_photo_from_url.sh
   chmod +x run_on_cron_display_photo_eink.sh
```
6. Add cron job(s)
```bash
   crontab -e
   # Example: Update e-ink screen with random photo every 2 hrs from 9 AM to 9 PM
   0 9-21/2 * * * /home/pi/projects/display-on-eink-random-photo/run_on_cron_display_photo_eink.sh
```
