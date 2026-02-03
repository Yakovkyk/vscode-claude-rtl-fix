<div dir="rtl">

# RTL Fix for Claude Code in VS Code

תמיכת RTL (עברית, ערבית, פרסית) עבור תוסף Claude Code ב-Visual Studio Code.

## מה זה עושה

תוסף Claude Code ב-VS Code מציג טקסט בעברית בכיוון הפוך (שמאל-לימין במקום ימין-לשמאל). הכלי הזה מתקן את זה על ידי הזרקת קוד JavaScript ל-webview של Claude Code.

**מה מכוסה:**
- הודעות צ'אט (של המשתמש ושל Claude)
- דיאלוגים של שאלות ואפשרויות (AskUserQuestion)
- דיאלוגי אישור (Permission requests)
- שדה הקלט (input box)
- בלוקי קוד נשארים LTR (כמו שצריך)

## למה צריך סקיל (ולא רק להתקין פעם אחת)

תוסף Claude Code **מתעדכן תכופות**. בכל עדכון, הקובץ שאליו מזריקים את הקוד מוחלף בגרסה נקייה - וה-RTL נעלם.

בנוסף, שמות ה-CSS classes של Claude Code הם **minified ומשתנים בין גרסאות**. כלומר, גם הקוד עצמו צריך עדכון כדי להתאים לשמות החדשים.

הסקיל (קובץ `SKILL.md`) מלמד את Claude Code לסרוק את הגרסה הנוכחית, לזהות את השמות הנכונים, לעדכן את הקוד, ולהזריק אותו מחדש - אוטומטית.

**הזרימה:**

1. תוסף Claude Code מתעדכן &larr; ה-RTL נעלם
2. אתה אומר ל-Claude: "תתקן לי את ה-RTL" (או מפעיל את הסקיל)
3. הוא סורק, מעדכן סלקטורים, מזריק מחדש
4. עובד שוב

## התקנה

### שלב 1: העתקת הקבצים

העתק את הקבצים לתיקייה במחשב שלך:

- הקובץ `rtl-claude-code.js` - קוד ה-RTL
- הקובץ `install.ps1` - סקריפט התקנה

### שלב 2: הרצת סקריפט ההתקנה

<div dir="ltr">

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

</div>

הסקריפט:
- מוצא אוטומטית את תיקיית Claude Code
- יוצר גיבוי של הקובץ המקורי
- מזריק את קוד ה-RTL

### שלב 3: הפעלה מחדש

<div dir="ltr">

```
Ctrl+Shift+P  -->  Reload Window
```

</div>

### שלב 4 (מומלץ): התקנת הסקיל

העתק את `SKILL.md` לתיקיית הסקילים של Claude Code:

<div dir="ltr">

```
~/.claude/skills/rtl-fix/SKILL.md
```

</div>

והעתק גם את הסקריפטים:

<div dir="ltr">

```
~/.claude/skills/rtl-fix/scripts/rtl-claude-code.js
~/.claude/skills/rtl-fix/scripts/install.ps1
```

</div>

מעכשיו, כשה-RTL יישבר (בגלל עדכון), פשוט תגיד ל-Claude: "תתקן לי את ה-RTL" והוא יעשה את הכל לבד.

## הסרה

שחזור מגיבוי:

<div dir="ltr">

```powershell
# Find the extension folder
ls $env:USERPROFILE\.vscode\extensions\anthropic.claude-code-*

# Restore backup
cp <path>\webview\index.js.backup <path>\webview\index.js
```

</div>

## מבנה הקבצים

<div dir="ltr">

```
claude-code-rtl-fix/
├── README.md              # הסבר והוראות התקנה
├── rtl-claude-code.js     # קוד ה-RTL (מוזרק ל-webview)
├── install.ps1            # סקריפט התקנה (PowerShell)
└── SKILL.md               # סקיל ל-Claude Code (לתחזוקה אוטומטית)
```

</div>

</div>
