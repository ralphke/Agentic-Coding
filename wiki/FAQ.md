# Participant FAQ

## What is this repository?

**Agentic-Coding** is a hands-on GitHub Copilot workshop repository. It teaches prompt quality, agent-first development, spec-driven workflows, and autonomous SDLC patterns across beginner, intermediate, and advanced levels.

## Who is this workshop for?

This workshop is intended for developers at multiple experience levels:

- **Beginner** — prompt crafting, chat context, and safe code generation
- **Intermediate** — tests, refactoring, and spec-driven development
- **Advanced** — issue-driven automation, CI/CD, and full agentic lifecycle workflows

## What should I install before the workshop?

At minimum, install and prepare:

- **VS Code Insiders**
- The **VS Code Agents application**
- A **GitHub account with GitHub Copilot access**

For local container-based work on macOS or Windows 11, also install:

- **Docker Desktop**

See `doc/setup.md` and `doc/environments.md` for detailed setup steps.

## What is the primary IDE for the workshop?

The workshop is designed around the **VS Code Agents application**, bundled with **VS Code Insiders**. The labs assume an agent-first workflow where chat is the primary interface.

## Can I use GitHub Codespaces instead of a local setup?

Yes. The repository supports **GitHub Codespaces** and shares the same `.devcontainer/devcontainer.json` configuration used for local devcontainers.

## What tools and runtimes are included in the devcontainer?

The recommended environment includes:

- **Python 3.14**
- **.NET 10 SDK**
- **.NET Aspire**
- **Data API Builder (DAB)**
- **Docker CLI**
- Supporting VS Code extensions such as Python, C# Dev Kit, Docker, and GitHub Copilot

## How do I verify my environment is working?

Run these commands in the devcontainer or Codespace terminal:

```bash
python3 --version
dotnet --version
dab --version
docker version
```

You should see installed versions for the core workshop tooling.

## Where should I start?

Start with these documents:

- `doc/setup.md`
- `doc/environments.md`
- `doc/workshop-roadmap.md`
- `lab/beginner/01-copilot-foundations.md`

## What are the workshop tracks?

### Beginner
- Prompt quality
- Chat context
- Safe code generation

### Intermediate
- Tests and refactoring
- Review loops
- Structured spec-driven development

### Advanced
- Issue-driven automation
- CI/CD with Copilot
- Agentic SDLC workflows

## Do I need to know Python or .NET in advance?

Not necessarily. The workshop uses both ecosystems to demonstrate realistic agent workflows, but the main learning goal is how to work effectively with GitHub Copilot and agentic delivery patterns.

## What does “agentic” mean in this workshop?

Here, **agentic** means working with Copilot as an implementation partner that can act on prompts, issues, specs, and workflow context — not just as an inline code completion tool.

## What is OpenSPEC and why does it matter to participants?

OpenSPEC is the structured specification model used in this repository’s advanced workflows. It helps define work through artifacts such as proposals, designs, and task lists so both humans and agents can work from shared context.

## How is work organized in the repository?

The main structure is:

- `.github/prompts` — saved workshop prompts
- `.github/workflows` — automation and CI
- `doc` — setup and workshop guidance
- `lab` — participant exercises by level
- `spec` — specifications and OpenSPEC artifacts
- `src` / `test` — exercise code and validation assets

---

# Maintainer FAQ

## What is the purpose of the maintainer workflow in this repository?

Maintainers use this repository to run, evolve, and extend a GitHub Copilot workshop. That includes keeping labs coherent, preserving prompt history, maintaining automation, and aligning documentation with the spec-driven workflow model.

## What is the recommended process for adding new workshop content?

When adding content:

1. Define the learning objective
2. Decide which audience level it belongs to
3. Add or update the relevant lab or documentation
4. Include expected outcomes and validation criteria
5. Record the build/update prompt in `.github/prompts` in chronological order

## Where should new prompts be stored?

All workshop build/update prompts should be saved in **`.github/prompts`** using chronological ordering with zero-padded numeric prefixes.

## What is the OpenSPEC structure in this repo?

In-flight and spec-driven changes are organized under `spec/openspec/`, including patterns such as:

- `spec/openspec/config.yaml`
- `spec/openspec/specs/<domain>/spec.md`
- `spec/openspec/changes/<slug>/proposal.md`
- `spec/openspec/changes/<slug>/design.md`
- `spec/openspec/changes/<slug>/tasks.md`

## How should maintainers start a new change?

Common entry points include:

- creating an issue from the idea capture template
- starting with a kickoff prompt
- using `/opsx:propose <slug>` to create the proposal flow
- using `/opsx:apply <slug>` to move into implementation
- using `/opsx:verify <slug>` to validate the change

## How is automation triggered?

The repository centers automation around GitHub workflows, the Copilot task template, and labels such as **`copilot-task`** so issues can be routed into implementation-oriented workflows.

## What do the PR stage labels represent?

The labels indicate progress through the SDLC pipeline, including stages such as:

- `stage:proposal`
- `stage:design`
- `stage:implement`
- `stage:test`
- `stage:security`
- `stage:review`
- `stage:deploy`
- `stage:operate`
- `archived`

## What should CI validate in this repository?

Current validation themes include:

- workshop file structure
- presence of devcontainer assets
- valid `devcontainer.json`
- `post-create.sh` shell validity expectations
- ordered prompt naming in `.github/prompts`

## How should maintainers think about environment support?

The repo is designed to support:

- local devcontainers on macOS
- local devcontainers on Windows 11
- GitHub Codespaces

Maintainers should keep these paths aligned so workshop participants get a consistent environment regardless of device.

## Can this repository be reused for internal training or team enablement?

Yes. It can serve as a reusable foundation for:

- Copilot workshops
- internal developer enablement
- spec-driven engineering experiments
- autonomous SDLC demonstrations

If you adapt it, keep prompts, workflows, docs, and specs consistent so the automation model remains understandable.

## What documents should maintainers keep aligned?

At minimum, keep these aligned when the workshop evolves:

- `README.md`
- `doc/setup.md`
- `doc/environments.md`
- `doc/workshop-roadmap.md`
- `spec/openspec/changes/README.md`

## When should content live in the wiki instead of the repository?

Use the wiki for reader-friendly, navigable reference material such as FAQs, onboarding notes, and workshop companion pages. Keep versioned operational assets — labs, specs, workflows, prompts, and environment configuration — in the repository itself.
