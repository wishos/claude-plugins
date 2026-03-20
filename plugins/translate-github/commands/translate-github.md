# Translate GitHub Command

## Usage

### 翻译 GitHub 项目文档

当用户说 `/translate-github`、`翻译文档`、`翻译这个项目`、`translate github docs`、`translate this project` 时：

按照下方「完整工作流」执行。

### 增量更新翻译

当用户说 `更新翻译`、`增量翻译`、`update translation` 时：

按照下方「完整工作流」执行（脚本会自动检测增量）。

### 查看翻译状态

当用户说 `翻译状态`、`translation status` 时：

执行脚本：
```
./plugins/translate-github/scripts/translate-github.sh status "$PWD"
```
展示结果给用户。

---

## 翻译规则（重要）

翻译目标：将英文文档翻译为高质量中文文档。严格遵循以下规则：

### 必须翻译的内容

- 正文段落
- 标题（各级 `#` 标题）
- 列表项文本
- 表格中的文本内容
- 图片的 alt 文本
- 引用块（`>` 块）中的文本
- 注意事项 / 警告框中的文本

### 绝不翻译的内容

- **代码块**：` ``` ` 包裹的代码块完整保留，包括代码中的注释
- **行内代码**：`` ` `` 包裹的内容保持原样
- **URL 和链接地址**：保留原始 URL，但链接文字需要翻译
- **命名标识符**：变量名、函数名、类名、文件名、命令名
- **品牌和专有名词**：如 GitHub、Docker、Kubernetes（首次出现可在括号中注释中文含义）
- **文件路径**：如 `/etc/config.yaml`
- **版本号**：如 v1.2.3

### 格式保持规则

- 保持原始的 Markdown 格式结构（标题层级、列表缩进、表格对齐）
- 保持原始的换行和空行
- 保持原始的链接格式：`[翻译后的文字](原始URL)`
- 保持 front matter（YAML 头部）的 key 不变，只翻译 value
- 保持 HTML 标签不变

### 翻译风格

- 使用自然流畅的中文，避免翻译腔
- 技术术语首次出现时用括号标注英文原文，如「依赖注入（Dependency Injection）」
- 后续出现可直接使用中文
- 保持专业性和准确性

---

## 完整工作流

### Phase 1：参数收集与初始化

1. 确认被翻译项目的根目录（默认使用当前工作目录 `$PWD`）
2. 询问用户要翻译哪些目录（如 `docs`、`guides`、`content` 等）
3. 执行初始化脚本：
   ```
   ./plugins/translate-github/scripts/translate-github.sh init "$PWD" <dir1> [dir2...]
   ```
4. 确认输出中包含 `READY`，表示初始化成功

### Phase 2：文件发现与翻译计划

5. 执行差异检测脚本：
   ```
   ./plugins/translate-github/scripts/translate-github.sh diff "$PWD" <dir1> [dir2...]
   ```
6. 解析脚本输出：
   - `FILE:<路径>` → 需要翻译的文件
   - `NEW_DIR:<路径>` → 来自新增目录、需要翻译的文件
   - `DELETED:<路径>` → 源文件已删除
   - `WARNING:COMMIT_UNREACHABLE` → 上次记录的 commit 不可达，已回退到全量模式
7. 如果无文件需要翻译（所有计数为 0），告知用户「所有文档已是最新，无需翻译」并结束
8. 向用户展示翻译计划：
   - 新增/修改文件数量和清单
   - 已删除文件（如有）
   - 确认后开始翻译

### Phase 3：逐文件翻译

对每个 `FILE:` 或 `NEW_DIR:` 文件：

9. 读取源文件：`<project-root>/<file-path>`
10. 按照上方「翻译规则」将内容翻译为中文
11. 将翻译结果写入：`<project-root>/wishos-docs/<file-path>`
12. 每完成一个文件，报告进度：`[3/15] ✓ docs/guide.md`

对 `DELETED:` 文件：

13. 提示用户：源文件 `<file-path>` 已被删除，是否同时删除 `wishos-docs/<file-path>` 下的译文？
14. 根据用户选择执行删除或保留

特殊情况处理：

- 如果源文件为空，跳过并报告
- 如果源文件已经是中文，跳过并报告
- 如果单个文件过大，分段读取和翻译

### Phase 4：保存状态与汇总

15. 执行保存状态脚本：
    ```
    ./plugins/translate-github/scripts/translate-github.sh save "$PWD" <dir1> [dir2...]
    ```
16. 输出翻译汇总报告：
    - 总计翻译 N 个文件
    - 新增 X 个 / 更新 Y 个
    - 删除 Z 个（如有）
    - 保存的 commit hash
    - 提示：下次运行时将从此 commit 开始增量翻译

---

## 注意事项

- 如果用户没有指定项目根目录，默认使用当前工作目录 `$PWD`
- 翻译过程中如果被中断，不执行 `save`，下次运行会自动重新检测变更
- `wishos-docs/` 目录保持与源目录完全一致的目录结构
- 保持输出美观清晰，使用 Unicode 符号标记进度

## 错误处理

- 脚本退出码非 0：读取错误输出，向用户说明具体原因
- 某个文件翻译失败：记录失败文件，继续翻译其他文件，最后汇报失败清单
- 翻译被中断：因为 `save` 未执行，下次运行自动恢复（已翻译的文件会被覆盖重译，保证幂等）
