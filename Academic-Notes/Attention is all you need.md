---
layout: page  # 使用Jekyll的“文章”布局，也可改为“page”（静态页面布局）
title: Attention is all you need 笔记  # 笔记标题，可自定义
---
# 📚 Transformer 模型解读笔记

**作者/报告人：** 何宇航 (北京科技大学) 
**报告日期：** 2025年11月6日
**文献来源：** *Attention Is All You Need* (Vaswani et al., 2017)

---

## 一、模型架构总览 (The Transformer Architecture)

Transformer 是一种 Seq2Seq (Sequence to Sequence) 模型，由一个 Encoder (编码器) 和一个 Decoder (解码器) 组成。

* **优点：** 并行计算效率高（矩阵运算），对长序列依赖关系的捕捉能力强（独特的注意力机制）。
* **核心机制：** **Self-Attention** 机制。

### 1. 整体流程

1.  **输入端 (Inputs)：** 原始输入序列。
2.  **编码器 (Encoder)：** 接收输入，负责将输入序列映射成连续的、包含语义信息的向量表示。
3.  **解码器 (Decoder)：** 接收编码器的输出和目标序列的（右移）输入，逐个生成输出序列。
4.  **输出端：** 经过 **Linear** 层 和 **Softmax** 层 转换为最终的输出概率分布。

---

## 二、输入准备：Embedding 与 Positional Encoding

在进入 Encoder/Decoder 之前，输入序列需要经过两个步骤处理：

### 1. Input Embedding (输入嵌入)

* **作用：** 将输入的每个元素（离散符号）映射到低维连续的向量空间，使其转化为更具语义信息的连续向量。
* **局限：** 仅提供词语的语义信息，**没有提供顺序信息**。

### 2. Positional Encoding (位置编码)

* **作用：** 为输入向量添加词语在句子中的**顺序信息**。
* **实现：** 将 `Input Embedding` 向量与 `Positional Encoding` 向量**相加**。
    $$
    \text{Final input vector} = \text{Input Embeddings} + \text{Positional Encodings}
    $$
* **公式：** 采用正弦和余弦函数（Sine and Cosine）定义。
    $$
    PE_{(pos,2i)}=\sin(pos/10000^{2i/d_{model}})
    $$
    $$
    PE_{(pos,2i+1)}=\cos(pos/10000^{2i/d_{model}})
    $$
* **优点：** 每个位置的编码是唯一的，并且包含**相对位置**信息。模型只需要学习相对关系，无需记住绝对位置。

---

## 三、核心机制：Self-Attention (自注意力)

Self-Attention 是整个 Transformer 的核心，用于捕获序列内部元素之间的依赖关系。

### 1. 动机与优势

* **解决 RNN 的问题：** 解决了其递归计算浪费时间的问题。
* **解决 CNN 的问题：** 解决了 CNN 难以捕捉远距离依赖的问题。

### 2. Q/K/V (Query, Key, Value) 矩阵

每个输入向量 $a^i$ 都会通过三个不同的线性变换（矩阵 $W^q, W^k, W^v$）生成三个新的向量：
$$
Q = I W^q \quad \text{(Query 矩阵)}
$$
$$
K = I W^k \quad \text{(Key 矩阵)}
$$
$$
V = I W^v \quad \text{(Value 矩阵)}
$$

### 3. 计算流程（Scaled Dot-Product Attention）

1.  **计算注意力分数 ($\alpha$)：** 使用查询 $q$ 和所有键 $k$ 进行点积（Dot-product）运算。
2.  **归一化 (Softmax)：** 将分数 $\alpha$ 经过 Softmax 函数转换为概率分布 $\alpha'$。
3.  **加权求和：** 用 $\alpha'$ 对所有 **Value** 向量 $v$ 进行加权求和，得到输出向量 $b^i$。
4.  **最终公式：**
    $$
    \text{Attention}(Q,K,V)=\text{softmax}(\frac{QK^{T}}{\sqrt{d_{k}}})V
    $$

---

## 四、Multi-Head Attention (多头注意力)

* **作用：** 增强模型的关注能力，使其能够同时关注序列中**不同类型**的相关性。
* **实现：** 将 $Q, K, V$ 拆分成多个“头” (Head)，每个头独立进行 Self-Attention 计算。
* **整合：** 将所有头的输出拼接在一起，然后通过一个额外的线性变换 $W^0$ 得到最终的输出向量 $b^i$。

---

## 五、其他关键组件

### 1. Add & Norm (残差连接与层归一化)

* **Add (残差连接 - Residual Connection)：** 将模块的输入与输出相加。
    * **作用：** 解决了深层网络的梯度消失/爆炸问题，保留了输入的原始信息。
* **Norm (层归一化 - Layer Normalization)：** 对每个样本的单个特征层内的所有元素进行归一化。
    * **作用：** 将特征约束在合理范围，减少特征尺度差异。

### 2. Feed Forward Network (FFN - 前馈网络)

* **结构：** 由两个线性变换组成，中间夹有 **ReLU** 激活函数。
    $$
    FFN(x)=\max(0,xW_{1}+b_{1})W_{2}+b_{2}
    $$
* **作用：** 通过升维和降维来实现**非线性加工**，让特征表达更精准。

---

## 六、Decoder 的特殊机制

### 1. Masked Self-Attention (掩码自注意力)

* **位置：** 在 Decoder 的第一个 Multi-Head Attention 子层。
* **作用：** 在训练阶段，遮盖未来位置的信息，避免模型“偷看”尚未生成的内容。

### 2. Cross-Attention (交叉注意力)

* **位置：** 在 Decoder 的第二个 Multi-Head Attention 子层。
* **作用：** 它是 **Decoder 连接 Encoder 的桥梁**，让 Decoder 动态关注源序列中相关的信息。
    * **Q** 向量来自 **Decoder**。
    * **K** 和 **V** 向量来自 **Encoder** 的最终输出。
