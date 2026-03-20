# Translate GitHub Command

## Usage

### 翻译 GitHub 项目文档

当用户说 `/translate-github`、`翻译文档`、`翻译这个项目`、`translate github docs`、`translate this project` 时：

按照下方「完整工作流」执行。

### 增量更新翻译

当用户说 `更新翻译`、`增量翻译`、`update translation` 时：

按照下方「完整工作流」执行（会自动检测增量）。

### 查看翻译状态

当用户说 `翻译状态`、`translation status` 时：

按照下方「状态查看流程」执行。

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

## 关键约定

- **项目根目录** `<PROJECT>`：被翻译的目标项目的根目录，默认为当前工作目录 `$PWD`
- **输出目录**：`<PROJECT>/wishos-docs/`，镜像源目录结构存放译文
- **状态文件**：`<PROJECT>/wishos-docs/.translate-state`，记录翻译版本状态
- **可翻译文件**：扩展名为 `.md`、`.txt`、`.rst` 的文件
- **排除目录**：`wishos-docs`、`node_modules`、`.git`、`vendor`、`dist`、`build`

### 状态文件格式

`wishos-docs/.translate-state` 是纯文本文件，格式如下：

```
# translate-github state file
LAST_COMMIT=<40位git commit hash>
LAST_RUN=<时间戳>
DIR=<目录1>
DIR=<目录2>
```

---

## 完整工作流

### Phase 1：参数收集与初始化

1. 确认被翻译项目的根目录 `<PROJECT>`（默认使用当前工作目录）
2. 确认 `<PROJECT>` 是 git 仓库（检查 `<PROJECT>/.git` 目录是否存在）
3. 询问用户要翻译哪些目录（如 `docs`、`guides`、`content` 等）
4. 验证用户指定的每个目录在 `<PROJECT>` 下存在
5. 创建 `<PROJECT>/wishos-docs/` 目录（如果不存在），使用 Bash `mkdir -p`
6. 为每个指定目录，递归镜像其子目录结构到 `wishos-docs/` 下：
   - 使用 Glob 工具查找指定目录下的所有子目录
   - 对每个子目录，用 Bash `mkdir -p` 在 `wishos-docs/` 下创建对应目录
   - 排除 `node_modules`、`.git`、`vendor`、`dist`、`build` 等目录

### Phase 2：文件发现与翻译计划

7. 读取状态文件 `<PROJECT>/wishos-docs/.translate-state`（如果存在），提取 `LAST_COMMIT` 和 `DIR=` 列表
8. 确定待翻译文件：

   **情况 A - 首次翻译**（无状态文件或无 LAST_COMMIT）：
   - 使用 Glob 工具在每个指定目录下查找 `**/*.md`、`**/*.txt`、`**/*.rst` 文件
   - 排除 `wishos-docs/`、`node_modules/`、`.git/` 等目录下的文件
   - 所有找到的文件标记为「新增」，需要全文翻译

   **情况 B - 增量翻译**（有 LAST_COMMIT）：
   - 先用 Bash 检查 LAST_COMMIT 是否可达：`git -C <PROJECT> cat-file -t <LAST_COMMIT>`
   - 如果不可达，回退到情况 A（全量模式），并告知用户原因
   - 如果可达，对每个指定目录：
     - **已记录目录**（在状态文件 DIR 列表中的）：
       - 用 Bash 执行 `git -C <PROJECT> diff --name-only --diff-filter=A <LAST_COMMIT> HEAD -- <dir>` 筛选新增文件（标记为「新增」）
       - 用 Bash 执行 `git -C <PROJECT> diff --name-only --diff-filter=M <LAST_COMMIT> HEAD -- <dir>` 筛选修改文件（标记为「修改」）
       - 分别筛选 `.md`/`.txt`/`.rst` 文件
     - **新增目录**（不在状态文件 DIR 列表中的）：走全量模式，Glob 查找所有可翻译文件，全部标记为「新增」
   - 用 Bash 执行 `git -C <PROJECT> diff --name-only --diff-filter=D <LAST_COMMIT> HEAD -- <dirs>` 检测已删除文件

9. 如果无文件需要翻译，告知用户「所有文档已是最新，无需翻译」并结束
10. 向用户展示翻译计划：
    - 新增文件数量和清单（将全文翻译）
    - 修改文件数量和清单（将仅翻译变更部分）
    - 已删除文件（如有）
    - 等待用户确认后开始翻译

### Phase 3：逐文件翻译

#### 3a. 新增文件 — 全文翻译

对每个标记为「新增」的文件：

11. 使用 Read 工具读取源文件：`<PROJECT>/<file-path>`
12. 按照上方「翻译规则」将完整内容翻译为中文
13. 使用 Write 工具将翻译结果写入：`<PROJECT>/wishos-docs/<file-path>`
14. 报告进度：`[3/15] ✓ docs/new-guide.md (新增，全文翻译)`

#### 3b. 修改文件 — 仅翻译变更部分

对每个标记为「修改」的文件：

15. 使用 Bash 获取该文件的具体变更内容：
    ```
    git -C <PROJECT> diff <LAST_COMMIT> HEAD -- <file-path>
    ```
16. 分析 diff 输出，识别变更类型：
    - **新增行**（`+` 开头的行）：需要翻译的新内容
    - **删除行**（`-` 开头的行）：需要从译文中移除的内容
    - **上下文行**（空格开头）：未变更的内容，用于定位变更位置
17. 使用 Read 工具读取已有的译文文件：`<PROJECT>/wishos-docs/<file-path>`
18. 根据 diff 信息，对已有译文进行局部更新：
    - 对于新增的段落/行：按「翻译规则」翻译后，插入到译文的对应位置
    - 对于删除的段落/行：从译文中移除对应的翻译内容
    - 对于修改的段落/行：找到译文中对应的翻译，用新翻译替换
    - 利用 diff 的上下文行和行号定位译文中的精确位置
19. 使用 Edit 工具对译文文件进行局部修改（而非 Write 重写整个文件）
20. 报告进度：`[5/15] ✓ docs/guide.md (修改，更新 3 处变更)`

**定位策略**：通过 diff 的 hunk header（`@@ -a,b +c,d @@`）和上下文行，在译文中找到对应位置。如果译文结构与源文件一一对应（Markdown 格式保持不变），可以按段落/标题/列表项进行精确匹配。

**回退机制**：如果修改过于复杂（如文件结构大幅重组），或无法精确定位译文中的对应位置，则回退到全文重新翻译。

#### 3c. 已删除文件

21. 提示用户：源文件已被删除，是否同时删除对应译文？
22. 如果用户同意，使用工具删除 `<PROJECT>/wishos-docs/<file-path>`

特殊情况处理：

- 如果源文件为空，跳过并报告
- 如果源文件已经是中文，跳过并报告
- 如果单个文件过大，分段读取和翻译

### Phase 4：保存状态与汇总

23. 使用 Bash 获取当前 commit hash：`git -C <PROJECT> rev-parse HEAD`
24. 使用 Write 工具写入状态文件 `<PROJECT>/wishos-docs/.translate-state`，内容格式：
    ```
    # translate-github state file
    LAST_COMMIT=<当前commit hash>
    LAST_RUN=<当前时间戳>
    DIR=<目录1>
    DIR=<目录2>
    ```
25. 输出翻译汇总报告：
    - 总计翻译 N 个文件
    - 新增 X 个（全文翻译） / 更新 Y 个（局部更新）
    - 删除 Z 个（如有）
    - 保存的 commit hash
    - 提示：下次运行时将从此 commit 开始增量翻译

---

## 状态查看流程

1. 确认项目根目录 `<PROJECT>`
2. 使用 Read 工具读取 `<PROJECT>/wishos-docs/.translate-state`
3. 如果文件不存在，告知用户「尚未初始化翻译」
4. 如果文件存在，解析并展示：
   - 上次翻译的 commit hash
   - 上次运行时间
   - 已翻译的目录列表
   - 使用 Bash `git -C <PROJECT> diff --name-only <LAST_COMMIT> HEAD -- <dirs>` 检查待翻译变更数量

---

## 注意事项

- 如果用户没有指定项目根目录，默认使用当前工作目录
- 翻译过程中如果被中断，不执行 Phase 4（保存状态），下次运行会自动重新检测变更
- `wishos-docs/` 目录保持与源目录完全一致的目录结构
- 保持输出美观清晰，使用 Unicode 符号标记进度
- 所有 git 命令使用 `git -C <PROJECT>` 指定项目目录，不需要 cd 进去

## 错误处理

- 项目根目录不是 git 仓库：告知用户并终止
- 指定目录不存在：告知用户具体哪个目录不存在
- 某个文件翻译失败：记录失败文件，继续翻译其他文件，最后汇报失败清单
- 翻译被中断：因为状态未保存，下次运行自动恢复（已翻译的文件会被覆盖重译，保证幂等）
