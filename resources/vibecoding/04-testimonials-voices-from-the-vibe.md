# Chapter 4: Testimonials - Voices from the Vibe

Five vibe coders. Five very different outcomes. Not every story is a success story.

## Klaus-Dieter "KD" Brandstetter

> "I don't vibe code. I architect, and the AI implements."

- Age / Location: 52, Stuttgart, Germany
- Role: Principal Software Engineer, automotive embedded systems
- Experience: 30+ years across C, C++, Java, Python, Rust, and JavaScript

KD started vibe coding "just to see what the fuss was about" after his niece built a working app in an afternoon. Three weeks later he had rebuilt a dashboard that had been stuck in Jira for eight months.

### Setup

- ThinkPad T14s running Arch Linux
- Keychron Q1 Pro mechanical keyboard
- Claude Pro
- Cursor Pro
- A leather-bound notebook for prompts

### What He Built

- Bericht-O-Mat, a reporting tool pulling from SAP, Oracle, and SharePoint
- A Raspberry Pi greenhouse monitor for his wife

### Workflow

He writes architectural specs on paper first, then translates them into precise prompts. He reviews every line.

### Best Prompt

> "Python ETL service: connect to Oracle 19c via cx_Oracle, pull WEEKLY_METRICS for last 7 days, normalize into a pandas DataFrame, handle NULLs with rolling 4-week averages, expose via FastAPI at /api/reports/weekly. Include connection pooling, retry with exponential backoff, structured logging, and pytest tests with mocked DB. Must pass mypy strict."

### What Works

- Boilerplate elimination
- Integration glue
- Test generation
- Exploring unfamiliar domains

### What Doesn't

- Legacy quirks nobody documented
- Real-time embedded constraints

### View of the Future

> "The craft isn't typing code. It never was. It's understanding systems - what to build, why, and what breaks at 3 AM. The keyboard was always just the bottleneck."

## Priya Chakraborty-Nilsson

> "The AI knows JavaScript. I know baking. Together we're dangerous."

- Age / Location: 37, Malmo, Sweden
- Role: Owner of "Mjol & Masala" fusion bakery, accidental SaaS founder
- Experience: effectively zero formal software background

A Le Cordon Bleu pastry chef, Priya was spending 20 hours a week on scheduling and inventory. After a developer quoted 180,000 SEK, she decided to build the software herself.

### Setup

- Refurbished MacBook Air M3
- Claude Pro
- Bolt.new
- Supabase and Vercel

### What She Built

- BakeryOS for production scheduling, inventory, staff shifts, and loyalty features
- A recipe calculator that later gained thousands of users

### Workflow

She describes what she wants like she's explaining it to a smart friend. When she gets stuck, she asks for an explanation "like I'm a baker, not a programmer."

### Best Prompt

> "Dashboard for my bakery staff. Tomorrow's date + weather forecast at top. Grid of recipe cards below - vintage look, warm cream background. Each card: product name, quantity, done-checkbox, bake timer. Bottom: total flour / butter / sugar needed. Highlight red if inventory is low. Big buttons - my bakers use it with floury hands."

### What Works

- UI prototyping
- CRUD and API integrations
- Translating domain expertise into software

### What Doesn't

- Deep debugging
- Scaling
- Security

### View of the Future

> "The future isn't 'everyone becomes a programmer.' It's 'everyone who has a problem can build a solution.'"

## Jayden "Jay" Okonkwo-Park

> "I'm not behind. Everyone else is catching up."

- Age / Location: 21, Austin, Texas
- Role: CS student at UT Austin
- Experience: AI-assisted coding is the only coding he's ever known

Jay started coding when ChatGPT arrived during his senior year and later landed a startup internship because his AI-built portfolio stood out.

### Setup

- MacBook Pro M4
- Claude Pro
- Cursor Pro
- Bolt.new
- Supabase and Vercel

### What He Built

- SplitFair, a bill-splitting app with OCR, proportional tax and tip, debt tracking, and automated nudges
- ProfScore, a professor rating app that quickly drew legal attention

### Workflow

He works visually: Figma mockup, then "build this," then rapid iteration. If something doesn't resolve in three tries, he starts over.

### Best Prompt

> "React Native bill-splitting screen. User snaps a receipt photo, OCR extracts items. Draggable cards assigned to people's avatars. Summary with proportional tax + tip slider (15-30%). Smooth animations - confetti burst when all items are assigned."

### What Works

- Speed
- Prototyping
- Frontend and mobile work
- Content creation

### What Doesn't

- Scaling
- Deep debugging
- Explaining fundamentals from first principles

### View of the Future

> "Every generation abstracts away the layer below. Clearly describing what you want, breaking problems into prompts, evaluating AI output - that is the new fundamental."

## Sandra "Sandy" Kowalski-Chen

> "Every company has a Sandy. The smart ones just don't know it yet."

- Age / Location: 44, Minneapolis, Minnesota
- Role: Senior Program Manager at Northland Mutual Insurance
- Experience: some old SQL and Access background

Sandy got tired of waiting 9 months and a six-figure budget for an internal dashboard request, so she built it herself in a weekend and did not tell IT.

### Setup

- Personal MacBook Air M2
- Phone hotspot at the office
- Claude Pro
- Burner GitHub account with private repos

### What She Built

- The Shadow Dashboard for real-time claims processing
- Form Killer, a Chrome extension that auto-fills internal forms

### Workflow

She works methodically in secret, mapping data sources on a whiteboard and building in 2 to 3 hour evening sessions.

### Best Prompt

> "Chrome extension for our internal portal. Floating 'Auto-fill' button. Reads field labels, matches against a JSON mapping, populates from my backend API. Must work without permissions that trigger corporate browser policy. Fail silently - no error popups that make someone call the help desk."

### What Works

- Bridging the gap between business needs and IT timelines
- Data tools
- Automation

### What Doesn't

- Security and compliance
- Corporate SSO
- COBOL mainframes

### View of the Future

> "Every company has someone who understands the business, has technical instinct, and is tired of waiting. Give us guardrails and we'll save you millions."

## Marcus Osei-Bonsu

> "I built the app in a weekend. I spent six weeks trying to fix it."

- Age / Location: 31, London, UK
- Role: Mid-level frontend developer at a fintech startup
- Experience: strong React and TypeScript, little backend or DevOps experience

Marcus volunteered to build an internal onboarding metrics tool over a weekend. The initial demo went well. The maintenance fallout did not.

### What Happened

The dashboard looked great and the data flowed, but the AI hadn't added indexes, performance collapsed, and each "make it faster" prompt changed architecture Marcus didn't fully understand. Six weeks later, he had a 14,000-line codebase he couldn't reason about.

### The Core Problem

Every "fix it" prompt changed code Marcus didn't understand. Each fix introduced new regressions. The AI happily helped, but it had no durable architectural memory.

### What He Learned

> "The AI is incredible at generating code. It's terrible at maintaining a coherent vision across 50 prompting sessions. That's your job."

### His Advice

- Understand every architectural decision before accepting it
- Stop and ask why the AI chose a pattern if you cannot explain it
- Don't let momentum replace comprehension
- Add database indexes before you have 5,000 rows

### Outcome

He scrapped the first version and rebuilt the project from scratch, this time with a spec-first and module-by-module workflow. The second version took two weeks and ran stably in production.
