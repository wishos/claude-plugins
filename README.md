<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Claude Plugins</title>
    <style>
        :root {
            --bg: #0d1117;
            --fg: #c9d1d9;
            --muted: #8b949e;
            --accent: #58a6ff;
            --border: #30363d;
            --code-bg: #161b22;
            --btn-bg: #21262d;
            --btn-hover: #30363d;
        }
        @media (prefers-color-scheme: light) {
            :root {
                --bg: #ffffff;
                --fg: #24292f;
                --muted: #57606a;
                --accent: #0969da;
                --border: #d0d7de;
                --code-bg: #f6f8fa;
                --btn-bg: #f3f4f6;
                --btn-hover: #e5e7eb;
            }
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            line-height: 1.6;
            background: var(--bg);
            color: var(--fg);
            max-width: 900px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }
        h1 { font-size: 2em; font-weight: 600; }
        h2 { font-size: 1.5em; margin: 30px 0 15px; font-weight: 600; }
        h3 { font-size: 1.2em; margin: 20px 0 10px; font-weight: 600; }
        p { color: var(--muted); margin-bottom: 15px; }
        a { color: var(--accent); text-decoration: none; }
        a:hover { text-decoration: underline; }
        code {
            background: var(--code-bg);
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.9em;
            font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, monospace;
        }
        pre {
            background: var(--code-bg);
            padding: 16px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 15px 0;
            border: 1px solid var(--border);
        }
        pre code { background: none; padding: 0; }
        ul, ol { margin: 10px 0 15px 25px; }
        li { margin: 5px 0; }
        .lang-switch {
            display: flex;
            gap: 8px;
        }
        .lang-switch button {
            background: var(--btn-bg);
            color: var(--fg);
            border: 1px solid var(--border);
            padding: 6px 14px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
        }
        .lang-switch button:hover { background: var(--btn-hover); }
        .lang-switch button.active {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
        }
        .plugin-card {
            background: var(--code-bg);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .plugin-name {
            font-size: 1.3em;
            font-weight: 600;
            margin-bottom: 8px;
        }
        .plugin-desc { color: var(--muted); margin-bottom: 15px; }
        .tag {
            display: inline-block;
            background: var(--btn-bg);
            color: var(--accent);
            padding: 2px 10px;
            border-radius: 20px;
            font-size: 12px;
            margin-right: 8px;
        }
        .section { margin-bottom: 25px; }
        .section-title {
            font-size: 0.9em;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }
        .folder-tree {
            font-family: ui-monospace, SFMono-Regular, monospace;
            font-size: 14px;
            line-height: 1.8;
        }
        .folder-tree .folder { color: var(--accent); }
        .folder-tree .file { color: var(--fg); }
        [lang="en"] { display: none; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Claude Plugins</h1>
        <div class="lang-switch">
            <button onclick="switchLang('zh')" class="active" id="btn-zh">中文</button>
            <button onclick="switchLang('en')" id="btn-en">EN</button>
        </div>
    </div>

    <div lang="zh">
        <p>wishos 自用的 Claude 插件集合。</p>

        <h2>插件列表</h2>

        <div class="plugin-card">
            <div class="plugin-name">git-multi-repo</div>
            <div class="plugin-desc">批量管理多个 git 仓库</div>
            <div class="section">
                <div class="section-title">功能</div>
                <span class="tag">批量更新</span>
                <span class="tag">分支切换</span>
            </div>
            <div class="section">
                <div class="section-title">触发语句</div>
                <code>帮我批量更新 git 库</code> · <code>update all git repos</code><br>
                <code>批量切换到 xxx 分支</code> · <code>switch all git repos</code>
            </div>
            <div class="section">
                <div class="section-title">使用</div>
                <pre><code>./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD"
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD" branch-name</code></pre>
            </div>
        </div>

        <h2>目录结构</h2>
        <div class="folder-tree">
<pre><span class="folder">plugins</span>/&lt;plugin-name&gt;/
├── <span class="folder">.claude-plugin</span>/
│   └── plugin.json
├── <span class="folder">commands</span>/
│   └── &lt;plugin-name&gt;.md
└── <span class="folder">scripts</span>/
    └── &lt;plugin-name&gt;.sh</pre>
        </div>
    </div>

    <div lang="en">
        <p>A collection of custom Claude plugins for wishos.</p>

        <h2>Plugins</h2>

        <div class="plugin-card">
            <div class="plugin-name">git-multi-repo</div>
            <div class="plugin-desc">Batch manage multiple git repositories</div>
            <div class="section">
                <div class="section-title">Features</div>
                <span class="tag">Batch Update</span>
                <span class="tag">Branch Switch</span>
            </div>
            <div class="section">
                <div class="section-title">Trigger</div>
                <code>帮我批量更新 git 库</code> · <code>update all git repos</code><br>
                <code>批量切换到 xxx 分支</code> · <code>switch all git repos</code>
            </div>
            <div class="section">
                <div class="section-title">Usage</div>
                <pre><code>./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD"
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD" branch-name</code></pre>
            </div>
        </div>

        <h2>Structure</h2>
        <div class="folder-tree">
<pre><span class="folder">plugins</span>/&lt;plugin-name&gt;/
├── <span class="folder">.claude-plugin</span>/
│   └── plugin.json
├── <span class="folder">commands</span>/
│   └── &lt;plugin-name&gt;.md
└── <span class="folder">scripts</span>/
    └── &lt;plugin-name&gt;.sh</pre>
        </div>
    </div>

    <script>
        const savedLang = localStorage.getItem('lang') || 'zh';
        switchLang(savedLang);

        function switchLang(lang) {
            document.querySelectorAll('[lang="zh"]').forEach(el => el.style.display = lang === 'zh' ? 'block' : 'none');
            document.querySelectorAll('[lang="en"]').forEach(el => el.style.display = lang === 'en' ? 'block' : 'none');
            document.getElementById('btn-zh').className = lang === 'zh' ? 'active' : '';
            document.getElementById('btn-en').className = lang === 'en' ? 'active' : '';
            document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en-US';
            localStorage.setItem('lang', lang);
        }
    </script>
</body>
</html>
