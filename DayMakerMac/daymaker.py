#!/usr/bin/env python3
"""
DayMaker for macOS
© 2026 Konstantinos Gkatidis. All rights reserved.
"""
import customtkinter as ctk
import tkinter as tk
from tkinter import messagebox
import json, os, threading, subprocess, urllib.request, urllib.error
from datetime import datetime, date, timedelta
from typing import Optional, List, Dict
import uuid, math, random

# ─── Setup ────────────────────────────────────────────────────────────────────

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

VERSION  = "1.0.0"
DATA_DIR = os.path.expanduser("~/Library/Application Support/DayMaker")
os.makedirs(DATA_DIR, exist_ok=True)

# Colors
PURPLE   = "#8B5CF6"; PURPLE_D = "#5B21B6"; PURPLE_L = "#A78BFA"
BLUE     = "#3B82F6"; PINK = "#EC4899"; GOLD = "#F59E0B"
GREEN    = "#10B981"; RED = "#EF4444"
BG       = "#0D0A1E"; CARD = "#1A1040"; SIDEBAR = "#110830"
TEXT     = "#F3F0FF"; TEXT2 = "#A78BFA"; BORDER = "#2D1F5E"
SLOT_COLORS = [GOLD, PURPLE, BLUE, PINK]

SLOTS = [
    {"key": "morning",   "hour": 8,  "emoji": "☀️", "label": "Morning Boost",  "context": "an energizing morning boost"},
    {"key": "midday",    "hour": 11, "emoji": "🌟", "label": "Midday Power",   "context": "a motivating midday message"},
    {"key": "afternoon", "hour": 15, "emoji": "⚡️", "label": "Afternoon Fire", "context": "an afternoon power-up"},
    {"key": "evening",   "hour": 20, "emoji": "🌙", "label": "Evening Glow",   "context": "a warm evening reflection"},
]

MOODS = [
    {"key": "amazing", "emoji": "🤩", "label": "Amazing", "context": "feeling absolutely amazing"},
    {"key": "good",    "emoji": "😊", "label": "Good",    "context": "in a genuinely good mood"},
    {"key": "neutral", "emoji": "😐", "label": "OK",      "context": "feeling neutral"},
    {"key": "down",    "emoji": "😔", "label": "Down",    "context": "feeling down and needing a boost"},
    {"key": "rough",   "emoji": "😞", "label": "Rough",   "context": "having a really rough day"},
]

QUESTIONS = [
    ("name",           "Πώς σε λένε;",                                    "Γράψε το όνομά σου..."),
    ("age",            "Πόσο χρονών είσαι;",                               "π.χ. 28"),
    ("occupation",     "Τι δουλειά κάνεις;",                               "π.χ. Software Engineer"),
    ("city",           "Σε ποια πόλη μένεις;",                             "π.χ. Αθήνα"),
    ("personality",    "Πώς θα περιέγραφες τον εαυτό σου;",                "π.χ. Δημιουργικός, φιλόδοξος..."),
    ("strengths",      "Ποιες είναι οι δυνατότητές σου;",                  "π.χ. Οργανωτικός, αποφασιστικός..."),
    ("goals",          "Ποιος είναι ο μεγάλος σου στόχος;",                "π.χ. Να ξεκινήσω τη δική μου εταιρεία..."),
    ("challenges",     "Τι σε δυσκολεύει περισσότερο;",                    "π.χ. Αναβλητικότητα, αυτοπεποίθηση..."),
    ("values",         "Τι πιστεύεις περισσότερο στη ζωή;",                "π.χ. Οικογένεια, ελευθερία, επιτυχία..."),
    ("interests",      "Τι σε ενδιαφέρει ή σε κάνει χαρούμενο;",          "π.χ. Μουσική, sport, ταξίδια..."),
    ("relationships",  "Πώς είναι οι σχέσεις σου με τους γύρω σου;",      "π.χ. Κοινωνικός, έχω στενούς φίλους..."),
    ("morning_routine","Πώς ξεκινάς συνήθως τη μέρα σου;",                "π.χ. Καφές, gym, μουσική..."),
    ("self_perception","Πώς βλέπεις τον εαυτό σου τώρα;",                  "π.χ. Καλύτερος απ' ό,τι ήμουν..."),
    ("dream",          "Αν μπορούσες να κάνεις οτιδήποτε;",               "π.χ. Να ταξιδέψω τον κόσμο..."),
    ("api_key",        "Claude API Key\n(console.anthropic.com → API Keys)", "sk-ant-..."),
]

# ─── Data Helpers ──────────────────────────────────────────────────────────────

def load_json(path: str, default):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except:
        return default

def save_json(path: str, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

# ─── Services ─────────────────────────────────────────────────────────────────

class ProfileService:
    _p: Dict = {}
    _c: List[Dict] = []

    @classmethod
    def load(cls):
        cls._p = load_json(DATA_DIR + "/profile.json", {})
        cls._c = load_json(DATA_DIR + "/compliments.json", [])

    @classmethod
    def save(cls):
        save_json(DATA_DIR + "/profile.json", cls._p)

    @classmethod
    def set(cls, k, v):
        cls._p[k] = v; cls.save()

    @classmethod
    def get(cls, k, default=""):
        return cls._p.get(k, default)

    @classmethod
    def is_complete(cls):
        return cls._p.get("onboarding_complete", False)

    @classmethod
    def api_key(cls):
        return cls._p.get("api_key", "")

    @classmethod
    def summary(cls) -> str:
        p = cls._p
        return (f"Name: {p.get('name','?')}, Age: {p.get('age','?')}, "
                f"Job: {p.get('occupation','?')}, City: {p.get('city','?')}, "
                f"Personality: {p.get('personality','?')}, "
                f"Strengths: {p.get('strengths','?')}, "
                f"Goals: {p.get('goals','?')}, "
                f"Challenges: {p.get('challenges','?')}, "
                f"Values: {p.get('values','?')}, "
                f"Interests: {p.get('interests','?')}, "
                f"Relationships: {p.get('relationships','?')}, "
                f"Morning: {p.get('morning_routine','?')}, "
                f"Self-view: {p.get('self_perception','?')}, "
                f"Dream: {p.get('dream','?')}")

    @classmethod
    def save_compliment(cls, c: Dict):
        cls._c.append(c)
        save_json(DATA_DIR + "/compliments.json", cls._c)

    @classmethod
    def update_compliment(cls, cid: str, **kw):
        for c in cls._c:
            if c["id"] == cid:
                c.update(kw)
        save_json(DATA_DIR + "/compliments.json", cls._c)

    @classmethod
    def todays(cls) -> List[Dict]:
        today = date.today().isoformat()
        return [c for c in cls._c if c.get("date", "").startswith(today)]

    @classmethod
    def all_compliments(cls) -> List[Dict]:
        return list(reversed(cls._c))

    @classmethod
    def favorites(cls) -> List[Dict]:
        return [c for c in reversed(cls._c) if c.get("is_favorite")]

    @classmethod
    def today_mood(cls) -> Optional[str]:
        return cls._p.get("mood_" + date.today().isoformat())

    @classmethod
    def set_mood(cls, key: str):
        cls._p["mood_" + date.today().isoformat()] = key
        cls.save()

    @classmethod
    def reset(cls):
        cls._p = {}; cls._c = []
        for f in ["profile.json", "compliments.json", "streak.json", "boost.json"]:
            try: os.remove(DATA_DIR + "/" + f)
            except: pass


class ClaudeService:
    URL   = "https://api.anthropic.com/v1/messages"
    MODEL = "claude-sonnet-4-6"
    FALLBACKS = {
        "morning": [
            "You are starting this day with everything you need. Trust yourself.",
            "This morning is yours. Own it from the very first breath.",
            "Every great day starts exactly like this — with you showing up.",
            "The energy you bring this morning sets the tone for everything that follows.",
        ],
        "midday": [
            "You've already accomplished more today than you give yourself credit for.",
            "Halfway through the day and still standing. That's not nothing — that's everything.",
            "Look at what you've already done. The second half is yours to dominate.",
            "The momentum you've built this morning? Keep it going. You're doing better than you think.",
        ],
        "afternoon": [
            "The best part of your day is still ahead. Keep your momentum going.",
            "Afternoon slumps are for people who don't know what they're capable of. You do.",
            "You've got more left in the tank than you realize. Push through — the finish line is worth it.",
            "This is the hour that separates the ones who show up from the ones who give up. You show up.",
        ],
        "evening": [
            "You made it through another day. That matters more than you know.",
            "Tonight, be proud. You faced today and you didn't back down.",
            "Every day you get through makes you stronger for the next one. Today counted.",
            "Rest well — you earned it. Tomorrow you'll do it all over again, even better.",
        ],
        "boost": [
            "You are exactly where you need to be. Keep showing up.",
            "Right now, in this moment, you have everything it takes.",
            "The version of you that existed a year ago would be proud of where you are today.",
            "You are more capable than your doubts tell you. Trust the work you've put in.",
            "Whatever is in front of you — you've handled harder. This is just the next thing.",
            "Your potential isn't a destination. It's already inside you, waiting to be used.",
            "Don't underestimate what consistency does. Every small action you take compounds.",
            "You were built for this. Not the easy version — the real version.",
        ],
    }

    @classmethod
    def _fallback(cls, key: str) -> str:
        return random.choice(cls.FALLBACKS.get(key, ["You've got this."]))

    @classmethod
    def _call(cls, prompt: str, key: str, max_tokens=300) -> str:
        payload = json.dumps({
            "model": cls.MODEL, "max_tokens": max_tokens,
            "messages": [{"role": "user", "content": prompt}]
        }).encode()
        req = urllib.request.Request(cls.URL, data=payload, method="POST", headers={
            "x-api-key": key, "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        })
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read())["content"][0]["text"].strip()

    @classmethod
    def compliment(cls, slot: Dict, mood: Optional[Dict], cb):
        def run():
            key  = ProfileService.api_key()
            name = ProfileService.get("name", "friend")
            mood_ctx = f" They are {mood['context']}." if mood else ""
            prompt = (f"You are DayMaker, a personal AI companion. "
                      f"User profile: {ProfileService.summary()}.{mood_ctx} "
                      f"Generate {slot['context']} for {name}. "
                      f"Be specific, warm, empowering. 2-3 sentences. "
                      f"No intro like 'Here is your...'. Just the message.")
            try:
                result = cls._call(prompt, key) if key else cls._fallback(slot["key"])
            except:
                result = cls._fallback(slot["key"])
            cb(result)
        threading.Thread(target=run, daemon=True).start()

    @classmethod
    def boost(cls, cb):
        def run():
            key = ProfileService.api_key()
            prompt = (f"You are DayMaker. User: {ProfileService.summary()}. "
                      f"Give a sudden, powerful, personalized motivational boost. "
                      f"2-3 sentences. Pure energy. No preamble.")
            try:
                result = cls._call(prompt, key) if key else cls._fallback("boost")
            except:
                result = cls._fallback("boost")
            cb(result)
        threading.Thread(target=run, daemon=True).start()

    @classmethod
    def soul_letter(cls, cb):
        def run():
            key = ProfileService.api_key()
            prompt = (f"You are DayMaker. User: {ProfileService.summary()}. "
                      f"Write a deep Sunday Soul Letter. Reflect on their week, struggles, strengths. "
                      f"Warm, wise, specific. 3-4 paragraphs.")
            soul_fallbacks = [
                "Dear soul, this week you showed up. That alone is worth celebrating.",
                "This week had its weight, and yet here you are. Still standing. Still trying. That is everything.",
                "You gave this week everything you had. Whatever came back — you handled it. That's who you are.",
            ]
            try:
                result = cls._call(prompt, key, 800) if key else random.choice(soul_fallbacks)
            except:
                result = random.choice(soul_fallbacks)
            cb(result)
        threading.Thread(target=run, daemon=True).start()

    @classmethod
    def monthly_letter(cls, cb):
        def run():
            key   = ProfileService.api_key()
            month = datetime.now().strftime("%B")
            prompt = (f"You are DayMaker. User: {ProfileService.summary()}. "
                      f"Write a Monthly Growth Letter for {month}. "
                      f"Celebrate growth, set intentions. 4-5 paragraphs. Inspiring and personal.")
            try:
                result = cls._call(prompt, key, 1000) if key else f"A new month begins. {month} holds infinite possibility for you. You've grown more than you know — now keep going."
            except:
                result = f"A new month begins. {month} holds infinite possibility for you. You've grown more than you know — now keep going."
            cb(result)
        threading.Thread(target=run, daemon=True).start()


class StreakService:
    F = DATA_DIR + "/streak.json"

    @classmethod
    def get(cls) -> int:
        d     = load_json(cls.F, {"s": 0, "last": ""})
        today = date.today().isoformat()
        yest  = (date.today() - timedelta(1)).isoformat()
        if d["last"] == today: return d["s"]
        if d["last"] == yest:
            d["s"] += 1; d["last"] = today; save_json(cls.F, d); return d["s"]
        if not d["last"]: return 0
        save_json(cls.F, {"s": 1, "last": today}); return 1

    @classmethod
    def touch(cls): cls.get()

    @classmethod
    def emoji(cls, s: int) -> str:
        return "🏆" if s >= 30 else "🌟" if s >= 14 else "🔥" if s >= 7 else "⚡️" if s >= 3 else "✨"


class BoostService:
    F = DATA_DIR + "/boost.json"
    MAX = 3

    @classmethod
    def remaining(cls) -> int:
        d = load_json(cls.F, {})
        if d.get("date") != date.today().isoformat(): return cls.MAX
        return max(0, cls.MAX - d.get("n", 0))

    @classmethod
    def use(cls) -> bool:
        if not cls.remaining(): return False
        d     = load_json(cls.F, {})
        today = date.today().isoformat()
        n     = 0 if d.get("date") != today else d.get("n", 0)
        save_json(cls.F, {"date": today, "n": n + 1})
        return True


class ScoreService:
    @classmethod
    def calc(cls) -> Dict:
        tc   = ProfileService.todays()
        mood = ProfileService.today_mood()
        s    = StreakService.get()
        mood_pts  = 20 if mood else 0
        streak_pts = min(20, s * 2)
        jrnl_pts  = min(20, sum(20 for c in tc if c.get("journal_note")))
        comp_pts  = min(40, len(tc) * 10)
        return {"total": min(100, mood_pts + streak_pts + jrnl_pts + comp_pts),
                "mood": mood_pts, "streak": streak_pts,
                "journal": jrnl_pts, "compliments": comp_pts}


class VoiceService:
    _proc = None

    @classmethod
    def speak(cls, text: str):
        cls.stop()
        clean = text.replace('"', "'")
        cls._proc = subprocess.Popen(["say", "-r", "175", clean])

    @classmethod
    def stop(cls):
        if cls._proc:
            cls._proc.terminate(); cls._proc = None


def notify(title: str, body: str):
    body_esc  = body.replace('"', "'")[:120]
    title_esc = title.replace('"', "'")
    script = f'display notification "{body_esc}" with title "{title_esc}" sound name "Glass"'
    subprocess.Popen(["osascript", "-e", script])


# ─── UI Widgets ───────────────────────────────────────────────────────────────

def card(parent, **kw):
    kw.setdefault("fg_color", CARD)
    kw.setdefault("corner_radius", 16)
    return ctk.CTkFrame(parent, **kw)

def lbl(parent, text, size=13, bold=False, color=TEXT2, **kw):
    return ctk.CTkLabel(parent, text=text, text_color=color,
                        font=ctk.CTkFont(size=size, weight="bold" if bold else "normal"), **kw)

def primary_btn(parent, text, cmd, color=PURPLE, width=140, **kw):
    return ctk.CTkButton(parent, text=text, command=cmd,
                         fg_color=color, hover_color=PURPLE_D,
                         font=ctk.CTkFont(size=13, weight="bold"),
                         corner_radius=10, width=width, **kw)

def icon_btn(parent, icon, cmd, size=34, tip_color=BORDER, **kw):
    return ctk.CTkButton(parent, text=icon, command=cmd,
                         width=size, height=size, fg_color="transparent",
                         hover_color=tip_color, corner_radius=8,
                         font=ctk.CTkFont(size=17), **kw)


def draw_score_ring(canvas: tk.Canvas, score: int, size=120):
    canvas.delete("all")
    cx, cy = size // 2, size // 2
    r = size // 2 - 12
    color = GREEN if score >= 80 else PURPLE if score >= 50 else GOLD if score >= 30 else RED
    canvas.create_oval(cx - r, cy - r, cx + r, cy + r, outline=BORDER, width=8)
    if score > 0:
        extent = -score / 100 * 359.9
        canvas.create_arc(cx - r, cy - r, cx + r, cy + r,
                          start=90, extent=extent,
                          outline=color, width=8, style="arc")
    canvas.create_text(cx, cy - 8, text=str(score), fill=TEXT,
                       font=("Helvetica", 22, "bold"))
    canvas.create_text(cx, cy + 14, text="score", fill=TEXT2,
                       font=("Helvetica", 10))


# ─── Dialogs ──────────────────────────────────────────────────────────────────

class JournalDialog(ctk.CTkToplevel):
    def __init__(self, parent, compliment: Dict, on_save):
        super().__init__(parent)
        self.title("Journal Note")
        self.geometry("520x380")
        self.resizable(False, False)
        self.configure(fg_color=BG)
        self._cid = compliment["id"]
        self._on_save = on_save

        lbl(self, "✍️  Journal", size=20, bold=True, color=TEXT).pack(pady=(24, 4))
        lbl(self, compliment.get("text", "")[:80] + "...", size=12).pack(padx=24)

        self._box = ctk.CTkTextbox(self, height=160, fg_color=CARD,
                                   text_color=TEXT, font=ctk.CTkFont(size=13),
                                   corner_radius=12)
        self._box.pack(fill="x", padx=24, pady=16)
        existing = compliment.get("journal_note", "")
        if existing:
            self._box.insert("1.0", existing)

        primary_btn(self, "Save Note", self._save, width=200).pack(pady=4)
        lbl(self, "Private — only you can see this", size=11).pack(pady=(4, 16))

    def _save(self):
        note = self._box.get("1.0", "end").strip()
        self._on_save(self._cid, note)
        self.destroy()


class LetterDialog(ctk.CTkToplevel):
    def __init__(self, parent, title_text: str, body: str):
        super().__init__(parent)
        self.title(title_text)
        self.geometry("620x500")
        self.resizable(True, True)
        self.configure(fg_color=BG)

        lbl(self, title_text, size=20, bold=True, color=PURPLE_L).pack(pady=(24, 12))
        box = ctk.CTkTextbox(self, fg_color=CARD, text_color=TEXT,
                             font=ctk.CTkFont(size=14), corner_radius=12,
                             wrap="word")
        box.pack(fill="both", expand=True, padx=24, pady=(0, 16))
        box.insert("1.0", body)
        box.configure(state="disabled")

        bf = ctk.CTkFrame(self, fg_color="transparent")
        bf.pack(pady=(0, 20))
        primary_btn(bf, "🔊 Read Aloud", lambda: VoiceService.speak(body),
                    color=BLUE, width=130).pack(side="left", padx=6)
        primary_btn(bf, "✕ Close", self.destroy, color="#333", width=100).pack(side="left", padx=6)


class BoostDialog(ctk.CTkToplevel):
    def __init__(self, parent, app_ref):
        super().__init__(parent)
        self.title("⚡️ Instant Boost")
        self.geometry("500x320")
        self.resizable(False, False)
        self.configure(fg_color=BG)
        self._app = app_ref

        self._status = lbl(self, "⚡️  Generating your boost...", size=16, bold=True, color=PURPLE_L)
        self._status.pack(pady=(36, 16), padx=32)

        self._text = ctk.CTkTextbox(self, height=130, fg_color=CARD, text_color=TEXT,
                                    font=ctk.CTkFont(size=14), corner_radius=12,
                                    wrap="word")
        self._text.pack(fill="x", padx=28)
        self._text.configure(state="disabled")

        self._btns = ctk.CTkFrame(self, fg_color="transparent")
        self._btns.pack(pady=16)

        rem = BoostService.remaining()
        lbl(self, f"{rem} boost{'s' if rem!=1 else ''} remaining today",
            size=11, color=TEXT2).pack()

        ClaudeService.boost(self._on_result)

    def _on_result(self, text: str):
        def update():
            self._status.configure(text="⚡️  Your Boost")
            self._text.configure(state="normal")
            self._text.delete("1.0", "end")
            self._text.insert("1.0", text)
            self._text.configure(state="disabled")

            c = {
                "id": str(uuid.uuid4()), "text": text,
                "slot": "boost", "date": datetime.now().isoformat(),
                "is_favorite": False, "journal_note": "",
            }
            ProfileService.save_compliment(c)

            icon_btn(self._btns, "🔊 Listen", lambda: VoiceService.speak(text)).pack(side="left", padx=6)
            icon_btn(self._btns, "❤️ Save",
                     lambda: (ProfileService.update_compliment(c["id"], is_favorite=True),
                               notify("DayMaker", "Saved to Favorites!"))).pack(side="left", padx=6)
            icon_btn(self._btns, "✕ Close", self.destroy).pack(side="left", padx=6)
            notify("⚡️ DayMaker Boost", text[:80])
        self._app.after(0, update)


# ─── Onboarding ───────────────────────────────────────────────────────────────

class OnboardingView(ctk.CTkFrame):
    def __init__(self, parent, on_complete):
        super().__init__(parent, fg_color=BG)
        self._on_complete = on_complete
        self._step = 0
        self._answers: Dict = {}
        self._build()

    def _build(self):
        for w in self.winfo_children():
            w.destroy()

        total = len(QUESTIONS)
        key, question, placeholder = QUESTIONS[self._step]

        # Progress bar
        prog_frame = ctk.CTkFrame(self, fg_color="transparent")
        prog_frame.pack(fill="x", padx=48, pady=(36, 0))
        lbl(prog_frame, f"Step {self._step + 1} of {total}", size=11).pack(anchor="e")
        bar = ctk.CTkProgressBar(prog_frame, fg_color=BORDER, progress_color=PURPLE,
                                  corner_radius=4, height=6)
        bar.pack(fill="x", pady=6)
        bar.set((self._step + 1) / total)

        # Logo
        lbl(self, "☀️  DayMaker", size=28, bold=True, color=TEXT).pack(pady=(32, 0))
        lbl(self, "Η εφαρμογή που φτιάχνει τη μέρα σου", size=13, color=TEXT2).pack(pady=(4, 32))

        # Question card
        q_card = card(self)
        q_card.pack(fill="x", padx=80, pady=8)

        lbl(q_card, question, size=18, bold=True, color=TEXT).pack(padx=28, pady=(24, 16))

        if key == "api_key":
            self._entry = ctk.CTkEntry(q_card, placeholder_text=placeholder,
                                       show="•", fg_color=SIDEBAR,
                                       border_color=BORDER, text_color=TEXT,
                                       font=ctk.CTkFont(size=13), height=44,
                                       corner_radius=10)
        else:
            self._entry = ctk.CTkEntry(q_card, placeholder_text=placeholder,
                                       fg_color=SIDEBAR, border_color=BORDER,
                                       text_color=TEXT, font=ctk.CTkFont(size=13),
                                       height=44, corner_radius=10)

        self._entry.pack(fill="x", padx=28, pady=(0, 24))
        if key in self._answers:
            self._entry.insert(0, self._answers[key])
        self._entry.focus()
        self._entry.bind("<Return>", lambda e: self._next())

        # Buttons
        bf = ctk.CTkFrame(self, fg_color="transparent")
        bf.pack(pady=20)

        if self._step > 0:
            primary_btn(bf, "← Back", self._prev, color="#333", width=110).pack(side="left", padx=8)

        label = "Finish ✓" if self._step == len(QUESTIONS) - 1 else "Next →"
        primary_btn(bf, label, self._next, width=130).pack(side="left", padx=8)

        if key == "api_key":
            lbl(self, "Optional — the app works offline without a key.", size=11).pack(pady=4)

        lbl(self, "© 2026 Konstantinos Gkatidis", size=10, color=BORDER).pack(side="bottom", pady=12)

    def _next(self):
        key, _, _ = QUESTIONS[self._step]
        val = self._entry.get().strip()
        if not val and key not in ("api_key",):
            self._entry.configure(border_color=RED)
            return
        self._answers[key] = val
        self._step += 1
        if self._step >= len(QUESTIONS):
            self._finish()
        else:
            self._build()

    def _prev(self):
        key, _, _ = QUESTIONS[self._step]
        self._answers[key] = self._entry.get().strip()
        self._step -= 1
        self._build()

    def _finish(self):
        self._answers["onboarding_complete"] = True
        ProfileService._p = self._answers
        ProfileService.save()
        ProfileService.load()
        StreakService.touch()
        notify("☀️ Welcome to DayMaker!", f"Γεια σου, {self._answers.get('name', '')}! Είσαι έτοιμος.")
        self._on_complete()


# ─── Compliment Card ──────────────────────────────────────────────────────────

class ComplimentCard(ctk.CTkFrame):
    def __init__(self, parent, slot: Dict, compliment: Optional[Dict],
                 color: str, app_ref, on_refresh):
        super().__init__(parent, fg_color=CARD, corner_radius=16)
        self._slot      = slot
        self._comp      = compliment
        self._color     = color
        self._app       = app_ref
        self._on_refresh = on_refresh
        self._loading   = False
        self._build()

    def _build(self):
        for w in self.winfo_children():
            w.destroy()

        # Header bar
        hf = ctk.CTkFrame(self, fg_color=self._color + "33", corner_radius=12)
        hf.pack(fill="x", padx=12, pady=(12, 0))

        row = ctk.CTkFrame(hf, fg_color="transparent")
        row.pack(fill="x", padx=14, pady=10)
        lbl(row, f"{self._slot['emoji']}  {self._slot['label']}",
            size=14, bold=True, color=TEXT).pack(side="left")

        if self._comp and self._comp.get("is_favorite"):
            lbl(row, "❤️", size=14, color=PINK).pack(side="right")

        # Body
        if self._comp:
            text = self._comp.get("text", "")
            tb = ctk.CTkTextbox(self, height=80, fg_color="transparent",
                                text_color=TEXT, font=ctk.CTkFont(size=13),
                                wrap="word", activate_scrollbars=False)
            tb.pack(fill="x", padx=16, pady=8)
            tb.insert("1.0", text)
            tb.configure(state="disabled")

            jn = self._comp.get("journal_note", "")
            if jn:
                lbl(self, f'✍️ "{jn[:60]}..."', size=11, color=TEXT2).pack(padx=16, anchor="w")

            # Action row
            af = ctk.CTkFrame(self, fg_color="transparent")
            af.pack(fill="x", padx=12, pady=(4, 12))

            icon_btn(af, "🔊", lambda t=text: VoiceService.speak(t)).pack(side="left")
            fav_icon = "❤️" if not self._comp.get("is_favorite") else "💔"
            icon_btn(af, fav_icon, lambda: self._toggle_fav()).pack(side="left", padx=4)
            icon_btn(af, "✍️", lambda: self._open_journal()).pack(side="left")
            icon_btn(af, "🔄", lambda: self._regenerate(), tip_color=PURPLE_D).pack(side="right")

        elif self._loading:
            lbl(self, "✨  Generating your message...", size=13, color=TEXT2).pack(pady=24)
        else:
            now_h = datetime.now().hour
            if now_h >= self._slot["hour"]:
                primary_btn(self, f"✨ Generate {self._slot['label']}",
                            self._generate, color=self._color, width=220).pack(pady=20)
            else:
                lbl(self, f"Unlocks at {self._slot['hour']}:00", size=13, color=TEXT2).pack(pady=20)
                primary_btn(self, "Preview anyway", self._generate,
                            color="#333", width=160).pack(pady=(0, 16))

    def _generate(self):
        self._loading = True
        self._build()
        mood_key = ProfileService.today_mood()
        mood = next((m for m in MOODS if m["key"] == mood_key), None)
        ClaudeService.compliment(self._slot, mood,
                                  lambda t: self._app.after(0, lambda: self._on_gen(t)))

    def _regenerate(self):
        self._comp = None
        self._generate()

    def _on_gen(self, text: str):
        c = {
            "id": str(uuid.uuid4()), "text": text,
            "slot": self._slot["key"], "date": datetime.now().isoformat(),
            "is_favorite": False, "journal_note": "",
        }
        ProfileService.save_compliment(c)
        self._comp = c
        self._loading = False
        self._build()
        notify(f"{self._slot['emoji']} DayMaker", text[:80])
        StreakService.touch()

    def _toggle_fav(self):
        if not self._comp: return
        new_val = not self._comp.get("is_favorite", False)
        ProfileService.update_compliment(self._comp["id"], is_favorite=new_val)
        self._comp["is_favorite"] = new_val
        self._build()
        notify("DayMaker", "Saved to Favorites! ❤️" if new_val else "Removed from Favorites")

    def _open_journal(self):
        if not self._comp: return
        def on_save(cid, note):
            ProfileService.update_compliment(cid, journal_note=note)
            if self._comp: self._comp["journal_note"] = note
            self._build()
        JournalDialog(self._app, self._comp, on_save)


# ─── Home View ────────────────────────────────────────────────────────────────

class HomeView(ctk.CTkScrollableFrame):
    def __init__(self, parent, app_ref):
        super().__init__(parent, fg_color=BG, scrollbar_fg_color=BG)
        self._app = app_ref
        self.refresh()

    def refresh(self):
        for w in self.winfo_children():
            w.destroy()

        name   = ProfileService.get("name", "friend")
        streak = StreakService.get()
        score  = ScoreService.calc()
        today  = date.today()
        is_sun = today.weekday() == 6
        is_1st = today.day == 1

        # Greeting
        hour = datetime.now().hour
        greeting = "Καλημέρα" if hour < 12 else "Καλησπέρα" if hour >= 18 else "Καλό απόγευμα"
        lbl(self, f"{greeting}, {name}! ☀️", size=24, bold=True, color=TEXT).pack(anchor="w", padx=24, pady=(20, 4))
        lbl(self, today.strftime("%A, %d %B %Y"), size=12, color=TEXT2).pack(anchor="w", padx=24)

        # Streak + Score row
        top_row = ctk.CTkFrame(self, fg_color="transparent")
        top_row.pack(fill="x", padx=24, pady=16)

        # Streak card
        sc = card(top_row)
        sc.pack(side="left", fill="both", expand=True, padx=(0, 8))
        lbl(sc, f"{StreakService.emoji(streak)}  {streak} Day Streak",
            size=15, bold=True, color=TEXT).pack(padx=20, pady=(16, 4))
        lbl(sc, "Keep it going!", size=11).pack(padx=20, pady=(0, 16))

        # Score ring
        qc = card(top_row, width=140)
        qc.pack(side="right", padx=(8, 0))
        cv = tk.Canvas(qc, width=120, height=120, bg=CARD, highlightthickness=0)
        cv.pack(padx=10, pady=10)
        draw_score_ring(cv, score["total"])

        # Mood check-in
        mood_key = ProfileService.today_mood()
        mc = card(self)
        mc.pack(fill="x", padx=24, pady=(0, 12))
        if mood_key:
            mood = next((m for m in MOODS if m["key"] == mood_key), None)
            lbl(mc, f"Today you feel: {mood['emoji']} {mood['label']}", size=14, color=TEXT).pack(pady=16)
        else:
            lbl(mc, "How are you feeling today?", size=14, bold=True, color=TEXT).pack(pady=(16, 8))
            mf = ctk.CTkFrame(mc, fg_color="transparent")
            mf.pack(pady=(0, 16))
            for m in MOODS:
                def pick(mk=m["key"]):
                    ProfileService.set_mood(mk)
                    self.refresh()
                ctk.CTkButton(mf, text=f"{m['emoji']}\n{m['label']}",
                              command=pick, width=80, height=60,
                              fg_color=SIDEBAR, hover_color=PURPLE_D,
                              corner_radius=12,
                              font=ctk.CTkFont(size=11)).pack(side="left", padx=4)

        # Special letters
        if is_sun or is_1st:
            spc = card(self, fg_color="#1A0A30")
            spc.pack(fill="x", padx=24, pady=(0, 12))
            if is_sun:
                lbl(spc, "✉️  Soul Letter — Sunday Special", size=14, bold=True, color=PURPLE_L).pack(padx=20, pady=(16, 4))
                lbl(spc, "A deep personal letter, just for you", size=12).pack(padx=20)
                primary_btn(spc, "Open My Soul Letter", self._open_soul_letter,
                            color=PURPLE, width=200).pack(pady=12)
            if is_1st:
                lbl(spc, "🗓️  Monthly Growth Letter", size=14, bold=True, color=GOLD).pack(padx=20, pady=(16, 4))
                lbl(spc, "Your personal letter for this month", size=12).pack(padx=20)
                primary_btn(spc, "Open Monthly Letter", self._open_monthly_letter,
                            color=GOLD, width=200).pack(pady=12)

        # Compliment slots
        lbl(self, "Your Messages", size=15, bold=True, color=TEXT).pack(anchor="w", padx=24, pady=(8, 4))
        todays = ProfileService.todays()
        todays_by_slot = {c["slot"]: c for c in todays}

        for i, slot in enumerate(SLOTS):
            comp = todays_by_slot.get(slot["key"])
            cc   = ComplimentCard(self, slot, comp, SLOT_COLORS[i], self._app, self.refresh)
            cc.pack(fill="x", padx=24, pady=6)

        # Score breakdown
        sd = card(self)
        sd.pack(fill="x", padx=24, pady=(12, 4))
        lbl(sd, "Daily Score Breakdown", size=13, bold=True, color=TEXT).pack(padx=20, pady=(14, 6))
        for label_text, pts, max_pts in [
            ("😊 Mood check-in", score["mood"], 20),
            ("🔥 Streak", score["streak"], 20),
            ("✍️ Journal entries", score["journal"], 20),
            ("☀️ Messages read", score["compliments"], 40),
        ]:
            row = ctk.CTkFrame(sd, fg_color="transparent")
            row.pack(fill="x", padx=20, pady=2)
            lbl(row, label_text, size=12, color=TEXT).pack(side="left")
            lbl(row, f"{pts}/{max_pts}", size=12, bold=True, color=PURPLE_L).pack(side="right")
        lbl(sd, f"Total: {score['total']}/100", size=13, bold=True, color=TEXT).pack(padx=20, pady=(6, 14))

        lbl(self, "© 2026 Konstantinos Gkatidis", size=10, color=BORDER).pack(pady=16)

    def _open_soul_letter(self):
        dlg = LetterDialog(self._app, "✉️ Sunday Soul Letter", "Generating...")
        ClaudeService.soul_letter(
            lambda t: self._app.after(0, lambda: dlg._set_text(t))
            if hasattr(dlg, '_set_text') else None
        )
        def _set(text):
            try:
                for w in dlg.winfo_children():
                    if isinstance(w, ctk.CTkTextbox):
                        w.configure(state="normal")
                        w.delete("1.0", "end")
                        w.insert("1.0", text)
                        w.configure(state="disabled")
            except: pass
        dlg._set_text = _set
        ClaudeService.soul_letter(lambda t: self._app.after(0, lambda: _set(t)))

    def _open_monthly_letter(self):
        dlg = LetterDialog(self._app, "🗓️ Monthly Growth Letter", "Generating...")
        def _set(text):
            try:
                for w in dlg.winfo_children():
                    if isinstance(w, ctk.CTkTextbox):
                        w.configure(state="normal")
                        w.delete("1.0", "end")
                        w.insert("1.0", text)
                        w.configure(state="disabled")
            except: pass
        ClaudeService.monthly_letter(lambda t: self._app.after(0, lambda: _set(t)))


# ─── Favorites View ───────────────────────────────────────────────────────────

class FavoritesView(ctk.CTkScrollableFrame):
    def __init__(self, parent, app_ref):
        super().__init__(parent, fg_color=BG, scrollbar_fg_color=BG)
        self._app = app_ref
        self.refresh()

    def refresh(self):
        for w in self.winfo_children():
            w.destroy()
        favs = ProfileService.favorites()
        lbl(self, "❤️  Favorites Vault", size=22, bold=True, color=TEXT).pack(anchor="w", padx=24, pady=(20, 4))
        lbl(self, f"{len(favs)} saved messages", size=12).pack(anchor="w", padx=24, pady=(0, 16))
        if not favs:
            lbl(self, "No favorites yet.\nHit ❤️ on any message to save it here.", size=14, color=TEXT2).pack(pady=60)
            return
        for c in favs:
            fc = card(self)
            fc.pack(fill="x", padx=24, pady=6)
            slot = next((s for s in SLOTS if s["key"] == c.get("slot")), SLOTS[0])
            lbl(fc, f"{slot['emoji']} {slot['label']}  ·  {c['date'][:10]}",
                size=11, color=TEXT2).pack(anchor="w", padx=16, pady=(12, 4))
            tb = ctk.CTkTextbox(fc, height=70, fg_color="transparent",
                                text_color=TEXT, font=ctk.CTkFont(size=13),
                                wrap="word", activate_scrollbars=False)
            tb.pack(fill="x", padx=16)
            tb.insert("1.0", c.get("text", ""))
            tb.configure(state="disabled")
            rf = ctk.CTkFrame(fc, fg_color="transparent")
            rf.pack(fill="x", padx=12, pady=8)
            icon_btn(rf, "🔊", lambda t=c.get("text",""): VoiceService.speak(t)).pack(side="left")
            icon_btn(rf, "💔", lambda cid=c["id"]: self._unfav(cid)).pack(side="left", padx=4)

    def _unfav(self, cid):
        ProfileService.update_compliment(cid, is_favorite=False)
        self.refresh()


# ─── History View ─────────────────────────────────────────────────────────────

class HistoryView(ctk.CTkScrollableFrame):
    def __init__(self, parent, app_ref):
        super().__init__(parent, fg_color=BG, scrollbar_fg_color=BG)
        self._app = app_ref
        self.refresh()

    def refresh(self):
        for w in self.winfo_children():
            w.destroy()
        all_c = ProfileService.all_compliments()
        lbl(self, "📋  History", size=22, bold=True, color=TEXT).pack(anchor="w", padx=24, pady=(20, 4))
        lbl(self, f"{len(all_c)} total messages", size=12).pack(anchor="w", padx=24, pady=(0, 16))
        if not all_c:
            lbl(self, "No messages yet.\nGenerate your first from Home.", size=14, color=TEXT2).pack(pady=60)
            return
        # Group by date
        by_date: Dict[str, List] = {}
        for c in all_c:
            d = c.get("date", "")[:10]
            by_date.setdefault(d, []).append(c)
        for day, items in by_date.items():
            lbl(self, day, size=13, bold=True, color=PURPLE_L).pack(anchor="w", padx=24, pady=(12, 4))
            for c in items:
                hc = card(self, fg_color=SIDEBAR)
                hc.pack(fill="x", padx=24, pady=3)
                slot = next((s for s in SLOTS if s["key"] == c.get("slot")), None)
                slot_label = f"{slot['emoji']} {slot['label']}" if slot else "⚡️ Boost"
                top = ctk.CTkFrame(hc, fg_color="transparent")
                top.pack(fill="x", padx=14, pady=(10, 4))
                lbl(top, slot_label, size=11, bold=True, color=TEXT2).pack(side="left")
                if c.get("is_favorite"):
                    lbl(top, "❤️", size=11).pack(side="right")
                lbl(hc, c.get("text", "")[:100] + ("..." if len(c.get("text","")) > 100 else ""),
                    size=12, color=TEXT).pack(anchor="w", padx=14, pady=(0, 10))


# ─── Profile View ─────────────────────────────────────────────────────────────

class ProfileView(ctk.CTkScrollableFrame):
    def __init__(self, parent, app_ref):
        super().__init__(parent, fg_color=BG, scrollbar_fg_color=BG)
        self._app = app_ref
        self._entries: Dict = {}
        self.refresh()

    def refresh(self):
        for w in self.winfo_children():
            w.destroy()
        p = ProfileService.profile()

        lbl(self, "⚙️  Profile & Settings", size=22, bold=True, color=TEXT).pack(anchor="w", padx=24, pady=(20, 4))
        lbl(self, "Your details are used to personalise every message", size=12).pack(anchor="w", padx=24, pady=(0, 16))

        # Editable fields
        editable = ["name","age","occupation","city","personality","strengths",
                    "goals","challenges","values","interests","morning_routine","dream"]
        labels   = {"name":"Name","age":"Age","occupation":"Occupation","city":"City",
                    "personality":"Personality","strengths":"Strengths","goals":"Goals",
                    "challenges":"Challenges","values":"Values","interests":"Interests",
                    "morning_routine":"Morning Routine","dream":"Dream"}

        fc = card(self)
        fc.pack(fill="x", padx=24, pady=8)
        lbl(fc, "Your Profile", size=14, bold=True, color=TEXT).pack(anchor="w", padx=20, pady=(14, 8))

        for key in editable:
            row = ctk.CTkFrame(fc, fg_color="transparent")
            row.pack(fill="x", padx=20, pady=3)
            lbl(row, labels.get(key, key), size=12, color=TEXT2).pack(anchor="w")
            e = ctk.CTkEntry(row, fg_color=SIDEBAR, border_color=BORDER,
                             text_color=TEXT, font=ctk.CTkFont(size=13),
                             height=36, corner_radius=8)
            e.pack(fill="x", pady=(2, 0))
            e.insert(0, p.get(key, ""))
            self._entries[key] = e

        primary_btn(fc, "Save Changes", self._save, width=180).pack(pady=14)

        # API Key
        ac = card(self)
        ac.pack(fill="x", padx=24, pady=8)
        lbl(ac, "Claude API Key", size=14, bold=True, color=TEXT).pack(anchor="w", padx=20, pady=(14, 4))
        lbl(ac, "Get yours at console.anthropic.com", size=11).pack(anchor="w", padx=20)
        self._api_entry = ctk.CTkEntry(ac, placeholder_text="sk-ant-...",
                                       show="•", fg_color=SIDEBAR,
                                       border_color=BORDER, text_color=TEXT,
                                       font=ctk.CTkFont(size=13), height=36, corner_radius=8)
        self._api_entry.pack(fill="x", padx=20, pady=8)
        if p.get("api_key"):
            self._api_entry.insert(0, p.get("api_key"))
        primary_btn(ac, "Save API Key", self._save_api, color=BLUE, width=160).pack(pady=(0, 14))

        # Stats
        sc = card(self)
        sc.pack(fill="x", padx=24, pady=8)
        lbl(sc, "Statistics", size=14, bold=True, color=TEXT).pack(anchor="w", padx=20, pady=(14, 8))
        streak = StreakService.get()
        total  = len(ProfileService.all_compliments())
        favs   = len(ProfileService.favorites())
        for row_data in [(f"🔥 Current streak", f"{streak} days"),
                          (f"☀️ Total messages", str(total)),
                          (f"❤️ Favorites saved", str(favs))]:
            row = ctk.CTkFrame(sc, fg_color="transparent")
            row.pack(fill="x", padx=20, pady=2)
            lbl(row, row_data[0], size=13, color=TEXT).pack(side="left")
            lbl(row, row_data[1], size=13, bold=True, color=PURPLE_L).pack(side="right")
        lbl(sc, "", size=4).pack()

        # Reset
        dc = card(self, fg_color="#1A0A0A")
        dc.pack(fill="x", padx=24, pady=(8, 24))
        lbl(dc, "Reset Everything", size=14, bold=True, color=RED).pack(anchor="w", padx=20, pady=(14, 4))
        lbl(dc, "Deletes all data and restarts onboarding", size=11).pack(anchor="w", padx=20)
        primary_btn(dc, "Reset App", self._reset, color=RED, width=140).pack(pady=12)

    def _save(self):
        for key, entry in self._entries.items():
            val = entry.get().strip()
            if val: ProfileService.set(key, val)
        notify("DayMaker", "Profile saved!")

    def _save_api(self):
        key = self._api_entry.get().strip()
        if key: ProfileService.set("api_key", key)
        notify("DayMaker", "API Key saved!")

    def _reset(self):
        if messagebox.askyesno("Reset DayMaker",
                               "Delete all data and restart onboarding?"):
            ProfileService.reset()
            self._app.show_onboarding()


# ─── Sidebar ──────────────────────────────────────────────────────────────────

class Sidebar(ctk.CTkFrame):
    NAV = [("🏠", "Home"), ("❤️", "Favorites"), ("📋", "History"), ("⚙️", "Profile")]

    def __init__(self, parent, app_ref):
        super().__init__(parent, fg_color=SIDEBAR, width=200, corner_radius=0)
        self.pack_propagate(False)
        self._app      = app_ref
        self._btns     = {}
        self._active   = "Home"
        self._build()

    def _build(self):
        lbl(self, "☀️", size=28, color=GOLD).pack(pady=(24, 0))
        lbl(self, "DayMaker", size=16, bold=True, color=TEXT).pack(pady=(4, 4))
        lbl(self, "v" + VERSION, size=10, color=TEXT2).pack()

        sep = ctk.CTkFrame(self, fg_color=BORDER, height=1)
        sep.pack(fill="x", padx=16, pady=16)

        for icon, name in self.NAV:
            b = ctk.CTkButton(self, text=f"  {icon}  {name}",
                              command=lambda n=name: self._nav(n),
                              anchor="w", height=44,
                              fg_color="transparent", hover_color=PURPLE_D,
                              text_color=TEXT, font=ctk.CTkFont(size=13),
                              corner_radius=10)
            b.pack(fill="x", padx=10, pady=2)
            self._btns[name] = b

        self._highlight("Home")

        # Streak at bottom
        self._streak_lbl = lbl(self, "", size=12, color=TEXT2)
        self._streak_lbl.pack(side="bottom", pady=(0, 8))
        copy_lbl = lbl(self, "© 2026 K. Gkatidis", size=9, color=BORDER)
        copy_lbl.pack(side="bottom", pady=2)
        self._update_streak()

    def _nav(self, name):
        self._highlight(name)
        self._app.navigate(name)

    def _highlight(self, active):
        self._active = active
        for name, btn_widget in self._btns.items():
            btn_widget.configure(
                fg_color=PURPLE if name == active else "transparent"
            )

    def _update_streak(self):
        s = StreakService.get()
        self._streak_lbl.configure(text=f"{StreakService.emoji(s)} {s} day streak")
        self.after(60000, self._update_streak)

    def boost_btn(self, cmd):
        sep = ctk.CTkFrame(self, fg_color=BORDER, height=1)
        sep.pack(fill="x", padx=16, pady=8)
        ctk.CTkButton(self, text="⚡️  Boost",
                      command=cmd, height=44,
                      fg_color=PURPLE_D, hover_color=PURPLE,
                      text_color=TEXT, font=ctk.CTkFont(size=13, weight="bold"),
                      corner_radius=10).pack(fill="x", padx=10, pady=2)


# ─── Main App ─────────────────────────────────────────────────────────────────

class DayMakerApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("DayMaker")
        self.geometry("1060x720")
        self.minsize(900, 640)
        self.configure(fg_color=BG)
        ProfileService.load()
        if ProfileService.is_complete():
            self.show_main()
        else:
            self.show_onboarding()

    def show_onboarding(self):
        for w in self.winfo_children():
            w.destroy()
        self._onboard = OnboardingView(self, self.show_main)
        self._onboard.pack(fill="both", expand=True)

    def show_main(self):
        for w in self.winfo_children():
            w.destroy()
        self._sidebar = Sidebar(self, self)
        self._sidebar.pack(side="left", fill="y")
        self._sidebar.boost_btn(self._open_boost)
        self._content = ctk.CTkFrame(self, fg_color=BG, corner_radius=0)
        self._content.pack(side="right", fill="both", expand=True)
        self._views: Dict = {}
        self.navigate("Home")
        self._schedule_day_check()

    def navigate(self, name: str):
        for w in self._content.winfo_children():
            w.pack_forget()
        if name not in self._views:
            cls_map = {
                "Home": HomeView, "Favorites": FavoritesView,
                "History": HistoryView, "Profile": ProfileView,
            }
            self._views[name] = cls_map[name](self._content, self)
        else:
            if hasattr(self._views[name], "refresh"):
                self._views[name].refresh()
        self._views[name].pack(fill="both", expand=True)

    def _open_boost(self):
        rem = BoostService.remaining()
        if rem == 0:
            messagebox.showinfo("DayMaker", "You've used all 3 boosts for today.\nCome back tomorrow! 💪")
            return
        if BoostService.use():
            BoostDialog(self, self)

    def _schedule_day_check(self):
        now  = datetime.now()
        for slot in SLOTS:
            target = now.replace(hour=slot["hour"], minute=0, second=0, microsecond=0)
            if target > now:
                delay_ms = int((target - now).total_seconds() * 1000)
                self.after(delay_ms, lambda s=slot: notify(
                    f"{s['emoji']} DayMaker", f"Your {s['label']} is ready!"))
        self.after(3600000, self._schedule_day_check)


def main():
    app = DayMakerApp()
    app.mainloop()

if __name__ == "__main__":
    main()
