# Training Programs Reference

Templates and patterns for building AI product training curricula.

## Training Program Structure

### Audience Segmentation

| Audience | Background | Goals | Format |
| ---------- | ----------- | ------- | -------- |
| **Business users** | Non-technical | Understand capabilities, make decisions | Presentations, demos |
| **Developers** | Programming skills | Integrate API, build apps | Tutorials, code labs |
| **ML engineers** | ML background | Fine-tune, deploy, optimize | Technical guides, notebooks |
| **Admins/DevOps** | Infra background | Deploy, monitor, scale | Runbooks, architecture docs |

### Curriculum Template

```markdown
# [Product] Training Program

## Level 1: Getting Started (1 hour)
### 1.1 Introduction (15 min)
- What is [Product]?
- Key use cases and capabilities
- Architecture overview (high-level)
- Live demo

### 1.2 Quick Start (30 min)
- Create account / get API key
- First API call (curl + Python)
- Explore the playground / demo UI
- Hands-on exercise: [simple task]

### 1.3 Core Concepts (15 min)
- Key terminology
- How the model works (intuition, not math)
- Limitations and best practices

---

## Level 2: Integration (2 hours)
### 2.1 API Deep Dive (30 min)
- Full API reference walkthrough
- Authentication and rate limits
- Request/response formats
- Error handling

### 2.2 Streaming Integration (30 min)
- WebSocket setup
- Audio streaming patterns
- SSE for text streaming
- Connection management

### 2.3 Building an Application (60 min)
- [Framework]-specific integration guide
- Hands-on: Build a [specific app]
- Testing and debugging tips

---

## Level 3: Advanced Usage (4 hours)
### 3.1 Fine-Tuning (90 min)
- When to fine-tune vs prompt engineering
- Preparing training data
- LoRA fine-tuning walkthrough
- Evaluating fine-tuned models

### 3.2 Performance Optimization (60 min)
- Latency optimization techniques
- Batch processing vs streaming
- Caching strategies
- Cost optimization

### 3.3 Production Deployment (90 min)
- Docker deployment
- Scaling with Kubernetes
- Monitoring and alerting
- Security best practices

---

## Level 4: Expert (2 hours)
### 4.1 Custom Models (60 min)
- Architecture overview (technical)
- Training from scratch
- Custom evaluations

### 4.2 Enterprise Integration (60 min)
- Multi-tenant setup
- VPC deployment
- Compliance and audit
- SLA management
```

## Training Material Types

### Code Lab (Interactive Tutorial)

```markdown
# Code Lab: Build a Voice Assistant with Moshi

## Objective
Build a real-time voice assistant that uses Moshi for conversation.

## Prerequisites
- Python 3.10+
- API key (get it at [URL])
- Microphone + speakers

## Steps

### Step 1: Install Dependencies
```bash
# Moshi real package (open-source, self-hosted)
pip install moshi sounddevice numpy websockets
```

### Step 2: Connect to self-hosted Moshi server

```python
import asyncio
import websockets

# Moshi exposes a WebSocket server — no API key needed (self-hosted)
MOSHI_URL = "ws://your-moshi-server:8998/api/chat"
```

### Step 3: Start Streaming

```python
async def stream_session():
    async with websockets.connect(MOSHI_URL) as ws:
        # Your code here — send/receive binary audio frames
        pass
```

### Step 4: Handle Audio I/O

[...step by step instructions...]

## Checkpoint

At this point, you should be able to [expected behavior].

## Challenge (Optional)

Extend the assistant to [advanced feature].

```TODO

### Jupyter Notebook (Data Science Training)

Structure for training notebooks:

1. **Introduction**: What we'll learn, prerequisites
2. **Setup**: Imports, configuration
3. **Data**: Load and explore data (interactive)
4. **Model**: Load or create model
5. **Train/Infer**: Run the main task
6. **Evaluate**: Analyze results
7. **Exercises**: Challenges for the learner

## Assessment Templates

### Knowledge Check

```markdown
## Quiz: API Fundamentals

1. What authentication method does the API use?
   a) OAuth2
   b) API key (Bearer token)  ← correct
   c) Basic auth
   d) Certificate-based

2. What is the maximum request rate for Pro tier?
   a) 10/minute
   b) 100/minute  ← correct
   c) 1000/minute
   d) Unlimited
```

### Practical Assessment

```markdown
## Practical Exercise: Build a Custom Voice App

### Requirements
- [ ] Connect to the API using WebSocket
- [ ] Stream audio input from microphone
- [ ] Display transcribed text in real-time
- [ ] Handle connection errors gracefully
- [ ] Add a custom system prompt

### Evaluation Criteria
- Code quality and error handling (30%)
- Correct API usage (30%)
- User experience (20%)
- Documentation/comments (20%)
```
