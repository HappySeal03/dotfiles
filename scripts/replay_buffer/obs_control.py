import os
import sys
import time
import subprocess
import logging
import obsws_python as obs

from dotenv import load_dotenv

logging.getLogger("obsws_python").setLevel(logging.CRITICAL)

load_dotenv()

HOST = os.getenv("HOST")
PORT = os.getenv("PORT")
PASSWORD = os.getenv("PASSWORD")

OBS_PROCESS = "obs"
OBS_PATH = "obs"

POLL_INTERVAL = 0.5
START_TIMEOUT = 10.0
STOP_TIMEOUT = 10.0

# Helper for desktop notifications.
def notify(message):
    try:
        subprocess.run(
            ["notify-send", "Replays", message],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except OSError:
        pass

# Detect if OBS is running
def is_running():
    client = None

    try:
        client = connect()
        client.get_version()
        return True
    except Exception:
        return False
    finally:
        if client is not None:
            try:
                client.disconnect()
            except Exception:
                pass

def wait_for_running(timeout=START_TIMEOUT):
    deadline = time.monotonic() + timeout

    while time.monotonic() < deadline:
        if is_running():
            return True

        time.sleep(POLL_INTERVAL)

    return False

def wait_for_stopped(timeout=STOP_TIMEOUT):
    deadline = time.monotonic() + timeout

    while time.monotonic() < deadline:
        if not is_running():
            return True

        time.sleep(POLL_INTERVAL)

    return False

# Connect to OBS
def connect():
    return obs.ReqClient(
        host=HOST,
        port=PORT,
        password=PASSWORD,
        timeout=2,
    )

# Run obs
def run():
    if is_running():
        return True

    try:
        subprocess.Popen(
            [OBS_PATH, "--minimize-to-tray"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            stdin=subprocess.DEVNULL,
            start_new_session=True,
        )
    except FileNotFoundError:
        print(
            f"Could not find OBS executable: {OBS_PATH}",
            file=sys.stderr,
        )
        return False
    except OSError as exc:
        print(f"Failed to start OBS: {exc}", file=sys.stderr)
        return False

    # Give OBS a few seconds to start its WebSocket server.
    if wait_for_running():
        return True

    print("OBS was started, but its WebSocket server did not become available.", file=sys.stderr)
    return False

# Stop obs
def stop():
    if not is_running():
        return True

    try:
        subprocess.run(
                    ["pkill", "-TERM", "-x", OBS_PROCESS],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
    except OSError as exc:
        print(f"Failed to stop OBS: {exc}", file=sys.stderr)
        return False

    # Wait for OBS to become unreachable.
    if wait_for_stopped():
        return True

    print("OBS did not stop.", file=sys.stderr)
    return False

# Get replay buffer status
def replay_status():
    client = connect()
    try:
        response = client.get_replay_buffer_status()

        active = getattr(response, "output_active", None)

        if active is None:
            raise RuntimeError(
                "OBS did not return replay buffer status."
            )

        return bool(active)
    finally:
        client.disconnect()

# Activate replay buffer
def start_replay():
    client = connect()
    try:
        client.start_replay_buffer()
    finally:
        client.disconnect()

# Stop replay buffer
def stop_replay():
    client = connect()
    try:
        client.stop_replay_buffer()
    finally:
        client.disconnect()

# Save replay buffer
def save_replay():
    client = connect()
    try:
        client.save_replay_buffer()
    finally:
        client.disconnect()

# Main
def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ("start", "stop", "status", "save"):
        print(
            f"Usage: {sys.argv[0]} {{start|stop|status|save}}",
            file=sys.stderr,
        )
        return 2

    action = sys.argv[1]

    try:
        if action == "start":
            # Start OBS if necessary, then start the replay buffer.
            if not run():
                return 1
            try:
                start_replay()
            except Exception:
                try:
                    if replay_status():
                        return 0
                except Exception:
                    pass

                print(
                    "Failed to start replay buffer.",
                    file=sys.stderr,
                )
                return 1

            notify("Replay buffer started")
            print("Replay buffer started.")
            return 0

        if action == "stop":
            if not is_running():
                return 0
            # Stop the replay buffer if it is active.
            try:
                if replay_status():
                    stop_replay()
                    notify("Replay buffer stopped")
            except Exception:
                pass
            # Stop OBS itself.
            if not stop():
                return 1

            print("OBS stopped.")
            return 0

        if action == "status":
            if not is_running():
                print("OBS: stopped")
                print("Replay buffer: unavailable")
                return 0

            try:
                active = replay_status()
            except Exception:
                print("OBS: running")
                print("Replay buffer: unavailable")
                return 0

            print("OBS: running")
            print(
                f"Replay buffer: {'running' if active else 'stopped'}"
            )
            return 0

        if action == "save":
            if not is_running():
                print("OBS is not running.", file=sys.stderr)
                return 1

            try:
                active = replay_status()
            except Exception:
                print(
                    "Could not query replay buffer status.",
                    file=sys.stderr,
                )
                return 1

            if not active:
                print(
                    "Replay buffer is not running.",
                    file=sys.stderr,
                )
                return 1

            try:
                save_replay()
            except Exception:
                print(
                    "Failed to save replay.",
                    file=sys.stderr,
                )
                return 1

            notify("Replay saved")
            print("Replay saved.")
            return 0

    except Exception as exc:
        print(f"OBS error: {exc}", file=sys.stderr)
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
