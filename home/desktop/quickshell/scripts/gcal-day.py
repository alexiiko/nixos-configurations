#!/usr/bin/env python3
"""gcal-day YYYY-MM-DD -> JSON events for that day, with resolved colours.

Reuses the token gcalcli stored (a pickled google.oauth2 Credentials), so
`gcalcli init` is still the one-time setup. Colours: an event's colorId maps
through the Calendar API colour table; events without one take the calendar's
own colour.
"""
import json, pickle, sys
from datetime import datetime, timedelta
from pathlib import Path

TOKEN = Path.home() / ".local/share/gcalcli/oauth"

def die(msg, code=1):
    print(msg, file=sys.stderr); sys.exit(code)

def main():
    if len(sys.argv) != 2: die("usage: gcal-day YYYY-MM-DD", 2)
    day = datetime.strptime(sys.argv[1], "%Y-%m-%d")
    if not TOKEN.exists(): die("not authenticated: run `gcalcli init`", 3)

    from googleapiclient.discovery import build
    with TOKEN.open("rb") as f:
        creds = pickle.load(f)
    svc = build("calendar", "v3", credentials=creds, cache_discovery=False)

    tz = datetime.now().astimezone().tzinfo
    start = day.replace(tzinfo=tz)
    end = start + timedelta(days=1)

    # The API only knows 11 event colour IDs (the web UI's 25 collapse onto
    # them) and reports the old pastel hexes; these are the modern UI colours.
    palette = {
        "1": "#7986cb", "2": "#33b679", "3": "#8e24aa", "4": "#e67c73", "5": "#f6c026", "6": "#f5511d",
        "7": "#039be5", "8": "#616161", "9": "#3f51b5", "10": "#0b8043", "11": "#d60000",
    }
    cal = svc.calendarList().get(calendarId="primary").execute()
    default_colour = cal.get("backgroundColor", "#4285f4")

    res = svc.events().list(
        calendarId="primary",
        timeMin=start.isoformat(), timeMax=end.isoformat(),
        singleEvents=True, orderBy="startTime",
    ).execute()

    out = []
    for e in res.get("items", []):
        s, en = e["start"], e["end"]
        all_day = "date" in s
        if all_day:
            sm, em = 0, 24 * 60
            st, et = "", ""
        else:
            sd = datetime.fromisoformat(s["dateTime"]).astimezone(tz)
            ed = datetime.fromisoformat(en["dateTime"]).astimezone(tz)
            # clamp to this day so multi-day events still render
            sd = max(sd, start); ed = min(ed, end)
            sm = sd.hour * 60 + sd.minute
            em = ed.hour * 60 + ed.minute if ed < end else 24 * 60
            st, et = sd.strftime("%H:%M"), ed.strftime("%H:%M")
        cid = e.get("colorId")
        colour = palette.get(cid, default_colour)
        out.append({
            "title": e.get("summary", "(no title)"),
            "start": st, "end": et, "startMin": sm, "endMin": em,
            "allDay": all_day, "color": colour,
        })
    json.dump({"events": out}, sys.stdout)

if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception as ex:  # auth errors, network, API errors
        die(f"{type(ex).__name__}: {ex}", 1)
