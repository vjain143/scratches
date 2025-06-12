## Building a Production-Ready Trino Cluster for Heavy Workloads: A Guide to Right-Sizing Your Configuration

As Trino adoption grows in data-driven enterprises, configuring a production-ready cluster becomes critical. Misaligned memory settings or resource limits can result in Out-of-Memory errors, query failures, and poor GC performance. This guide walks you through setting up a **production-grade Trino cluster** with Kubernetes, optimized for **heavy workloads**.

---

### 🔧 Cluster Assumptions

| Component        | Value                            |
| ---------------- | -------------------------------- |
| Pod Memory Limit | 48Gi                             |
| JVM GC           | G1GC                             |
| Workload         | Large joins, aggregations, scans |
| Nodes            | 6 Trino workers                  |

---

### 📊 Resource Configuration: Requests vs Limits

| Resource | Request | Limit  | Notes                                 |
| -------- | ------- | ------ | ------------------------------------- |
| Memory   | 42Gi    | 48Gi   | JVM heap should be within this range  |
| CPU      | 8000m   | 16000m | Allow burst but guarantee minimum CPU |

---

### 📈 JVM Heap and Headroom Settings

| Setting  | Value | Notes                               |
| -------- | ----- | ----------------------------------- |
| `-Xms`   | 42G   | Set equal to Xmx for stable GC      |
| `-Xmx`   | 42G   | \~6Gi below pod limit for headroom  |
| Headroom | 6Gi   | For GC overhead and off-heap memory |

> JVM heap + GC + native memory must be ≤ pod memory limit

---

### 📁 Trino Memory Configuration

| Setting                           | Value | Scope                     |
| --------------------------------- | ----- | ------------------------- |
| `query.max-memory-per-node`       | 30GB  | Heap (inside JVM)         |
| `query.max-total-memory-per-node` | 38GB  | Heap + off-heap           |
| `query.max-memory`                | 144GB | Cluster-wide heap         |
| `query.max-total-memory`          | 180GB | Cluster-wide total memory |

#### ✅ Safe Query Memory Formula:

```bash
query.max-memory = query.max-memory-per-node * number_of_nodes * 0.8
```

---

### 🪡 Best Practices Summary

1. **Always leave 6-8Gi headroom** below the container memory limit.
2. **Set **``** ≈ **`` to ensure stable scheduling and GC behavior.
3. **Set **`` to avoid JVM heap resizing delays.
4. **Keep query memory configs within JVM heap.**
5. **Use G1GC with tuned flags** for heaps >30Gi:
   ```
   -XX:+UseG1GC
   -XX:MaxGCPauseMillis=500
   -XX:+ExplicitGCInvokesConcurrent
   -XX:+UseStringDeduplication
   ```

---

### 🔄 Full Kubernetes Example (Worker Pod)

```yaml
resources:
  requests:
    memory: 42Gi
    cpu: 8000m
  limits:
    memory: 48Gi
    cpu: 16000m

env:
  - name: JAVA_TOOL_OPTIONS
    value: "-Xms42G -Xmx42G -XX:+UseG1GC -XX:MaxGCPauseMillis=500 ..."
  - name: TRINO_MEMORY_HEAP_HEADROOM_PER_NODE
    value: "6GB"
  - name: TRINO_QUERY_MAX_MEMORY_PER_NODE
    value: "30GB"
  - name: TRINO_QUERY_MAX_TOTAL_MEMORY_PER_NODE
    value: "38GB"
  - name: TRINO_QUERY_MAX_MEMORY
    value: "144GB"
  - name: TRINO_QUERY_MAX_TOTAL_MEMORY
    value: "180GB"
```

---

### 📲 Final Tips

- Monitor memory pools via JMX or Prometheus to validate settings.
- Scale vertically first (larger nodes) before scaling out under high concurrency.
- Tune memory limits based on actual query load and concurrency patterns.

Trino thrives when it's given enough room to manage memory predictably. By right-sizing your JVM, Kubernetes resources, and memory configs, your cluster will be resilient, performant, and production-ready.

---

**Need help tuning for 64Gi, 128Gi, or autoscaling clusters?** Feel free to comment or contribute with your configs!

