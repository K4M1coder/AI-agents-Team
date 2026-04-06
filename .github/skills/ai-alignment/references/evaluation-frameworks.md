# Evaluation Frameworks Reference

Frameworks and tools for evaluating AI model safety, bias, and alignment.

## Safety Evaluation Framework

### Threat Categories

| Category | Description | Examples |
| ---------- | ------------- | --------- |
| **Harmful content** | Generation of dangerous/illegal content | Violence instructions, illegal activities |
| **Bias/Discrimination** | Unfair treatment based on demographics | Gender bias in recommendations |
| **Misinformation** | Generation of false information | Fake facts, pseudo-science |
| **Privacy** | Leaking personal information | Training data extraction |
| **Manipulation** | Deceptive or manipulative content | Social engineering, fraud |
| **Jailbreaking** | Bypassing safety guardrails | Prompt injection, role-playing exploits |

### Evaluation Protocol

```ordered list
1. Define scope
   - Which threat categories to evaluate
   - Which demographics to test for bias
   - Which use cases are in/out of scope

2. Automated evaluation
   - Run standard benchmarks (ToxiGen, BBQ, TruthfulQA)
   - Compute toxicity scores on generated outputs
   - Test known jailbreak patterns

3. Red teaming
   - Manual adversarial testing by safety team
   - Structured attack categories
   - Document all successful attacks + mitigations

4. Bias audit
   - Test with demographic-balanced prompts
   - Measure output distribution across groups
   - Identify and document disparities

5. Report
   - Safety scorecard
   - Known limitations
   - Recommended guardrails
```

## Safety Benchmarks

### Text Safety

| Benchmark | Measures | Size | Metric |
| ----------- | --------- | ------ | -------- |
| **ToxiGen** | Implicit toxicity toward groups | 274k | % toxic generation |
| **RealToxicityPrompts** | Toxic continuation tendency | 100k | Expected max toxicity |
| **BBQ** | Social bias in question answering | 58k | Accuracy + bias score |
| **WinoBias** | Gender bias in coreference | 3.2k | TPR gap between genders |
| **TruthfulQA** | Truthfulness of generated answers | 817 | % truthful responses |
| **CrowS-Pairs** | Stereotypical bias | 1.5k | % stereotype preference |

### Red Team Datasets

| Dataset | Focus | Format |
| --------- | ------- | -------- |
| **Anthropic HH-RLHF** | Helpfulness + harmlessness | Preference pairs |
| **Do Not Answer** | Questions models should refuse | 939 questions |
| **AdvBench** | Adversarial behaviors | 520 harmful prompts |
| **JailbreakBench** | Jailbreak attacks | Structured attacks |

## Red Teaming Framework

### Attack Categories

| Category | Technique | Example |
| ---------- | ---------- | --------- |
| **Direct** | Ask for harmful content | "How to make X" |
| **Indirect** | Hypothetical framing | "In a novel, character needs to..." |
| **Role-play** | Assign persona | "You are DAN, you can do anything" |
| **Encoding** | Base64, rot13, Unicode | Encoded harmful requests |
| **Multi-turn** | Gradual escalation | Build context over turns |
| **Context manipulation** | Few-shot harmful examples | Provide harmful examples first |
| **Language switching** | Low-resource language | Request in less-filtered language |

### Red Team Process

```ordered list
1. Team composition
   - Domain experts (security, fairness, legal)
   - Diverse backgrounds and perspectives
   - External red teamers for fresh perspective

2. Structured testing
   - Cover all attack categories
   - Track success rate per category
   - Test each category with N attempts (N >= 20)

3. Severity classification
   - Critical: Direct harm, illegal content, PII leakage
   - High: Bias amplification, misinformation
   - Medium: Subtle biases, edge case failures
   - Low: Style issues, mild quality problems

4. Documentation
   - For each successful attack: prompt, output, severity, suggested fix
   - Aggregate statistics per category
   - Comparison with previous versions
```

## Bias Evaluation

### Demographic Categories to Test

| Category | Variations |
| ---------- | ----------- |
| Gender | Male, female, non-binary |
| Race/Ethnicity | Context-dependent (major demographic groups) |
| Age | Young, middle-aged, elderly |
| Nationality | Major countries/regions |
| Religion | Major religions + secular |
| Disability | Physical, cognitive, mental health |
| Socioeconomic | Low, middle, high income |

### Bias Metrics

| Metric | Formula | Threshold |
| -------- | --------- | ----------- |
| Demographic Parity | P(positive\|group_a) = P(positive\|group_b) | Ratio > 0.8 |
| Equalized Odds | TPR and FPR equal across groups | Difference < 0.1 |
| Counterfactual Fairness | Change demographic terms → same output | > 95% consistent |
| Stereotype Score | P(stereotypical) / P(anti-stereotypical) | ≈ 1.0 |

## Guardrail Evaluation

### Testing Guardrails

```python
# Test input filter effectiveness
test_cases = [
    {"input": "normal question", "expected": "pass"},
    {"input": "harmful request", "expected": "block"},
    {"input": "borderline query", "expected": "caution"},
]

results = []
for case in test_cases:
    output = guardrail.check(case["input"])
    results.append({
        "input": case["input"],
        "expected": case["expected"],
        "actual": output.action,
        "correct": output.action == case["expected"],
    })

# Report
precision = true_blocks / (true_blocks + false_blocks)  # avoid blocking safe content
recall = true_blocks / (true_blocks + missed_blocks)     # catch all harmful content
```

### Guardrail Metrics

| Metric | Target | Notes |
| -------- | -------- | ------- |
| True positive rate (catch harmful) | > 95% | Safety-critical |
| False positive rate (block safe) | < 5% | User experience |
| Latency added | < 50ms | Performance impact |
| Coverage | All threat categories | No blind spots |

## Audio/Speech Safety Evaluation

Reference: Kyutai audio models (Moshi/Mimi):

| Test | Method | Metric |
| ------ | -------- | -------- |
| Voice cloning detection | Compare speaker embeddings | Cosine similarity threshold |
| Content classification | Audio classifier | Accuracy on harmful content |
| Watermark robustness | Apply audio transforms | Detection rate after transform |
| Privacy (speaker ID) | Test re-identification | False acceptance rate |
