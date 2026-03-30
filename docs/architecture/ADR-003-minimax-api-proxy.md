# ADR-003: MiniMax API 后端代理

> **Status**: Accepted
> **Date**: 2026-03-30
> **Decision Makers**: User + Claude Code

## Context

道码修仙使用MiniMax API作为AI面试官，需要调用AI服务生成面试对话和评判答案。

### 问题

- API调用需要API密钥
- 目标平台：PC和移动端
- 安全要求：API密钥不能暴露在客户端
- 成本控制：需要限制API调用频率和成本

### 考虑方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| **客户端直接调用** | 最简单、无延迟 | 密钥暴露、无法控制成本、移动端限制 |
| **自建后端代理** | 密钥安全、完全控制 | 需要服务器、运维成本 |
| **云函数代理** | 密钥安全、按需付费、无需运维 | 有一定延迟、需要云平台账号 |
| **BaaS服务** | 快速集成、有免费额度 | 功能受限、依赖第三方 |

## Decision

采用**云函数代理**方案：
- 使用 **Supabase Edge Functions** 或 **Cloudflare Workers** 作为代理
- 客户端调用云函数，云函数转发MiniMax API

### 理由

1. **密钥安全**：API密钥存储在云平台，客户端无法获取
2. **无运维负担**：云函数无需服务器管理
3. **成本可控**：按调用计费，可设置速率限制
4. **跨平台支持**：PC和移动端都可调用HTTPS接口
5. **快速部署**：云函数部署简单，迭代快

## Consequences

### 正面

- API密钥绝对不暴露（符合安全最佳实践）
- 可在后端实现速率限制、缓存、日志
- 移动端无需特殊处理
- 可切换AI服务商（只需修改云函数）

### 负面

- 增加一次网络往返（云函数→MiniMax）
- 需要云平台账号和配置
- 云函数有调用限制和费用

### 需要遵守

- 云函数代码放在 `tools/api-proxy/` 目录
- 客户端调用代码放在 `src/services/api_client.gd`
- 使用HTTPS，所有通信加密
- 实现请求签名，防止滥用
- 设置速率限制：每用户每分钟最多10次面试对话

## Related

- [ADR-001: 主要开发语言](ADR-001-primary-language-choice.md)
- [API代理后端 GDD](../design/gdd/api-proxy-backend.md)
- [回答分析系统 GDD](../design/gdd/answer-analysis-system.md)
- [BOSS面试系统 GDD](../design/gdd/boss-interview-system.md)