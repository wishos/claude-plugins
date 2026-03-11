<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Claude Plugins</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }
        h1, h2, h3 {
            color: #24292e;
        }
        code {
            background: #f6f8fa;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
        }
        pre {
            background: #f6f8fa;
            padding: 16px;
            border-radius: 6px;
            overflow-x: auto;
        }
        pre code {
            background: none;
            padding: 0;
        }
        .lang-switch {
            text-align: right;
            margin-bottom: 20px;
        }
        .lang-switch button {
            background: #f6f8fa;
            border: 1px solid #d1d5da;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            margin-left: 8px;
        }
        .lang-switch button:hover {
            background: #e1e4e8;
        }
        .lang-switch button.active {
            background: #0366d6;
            color: white;
            border-color: #0366d6;
        }
        [lang="en"] {
            display: none;
        }
    </style>
</head>
<body>
    <div class="lang-switch">
        <button onclick="switchLang('zh')" class="active" id="btn-zh">中文</button>
        <button onclick="switchLang('en')" id="btn-en">English</button>
    </div>

    <div lang="zh">
        <h1>Claude Plugins</h1>
        <p>wishos 自用的 Claude 插件集合。</p>

        <h2>插件列表</h2>

        <h3>git-multi-repo</h3>
        <p>批量管理多个 git 仓库的插件。</p>

        <h4>功能</h4>
        <ul>
            <li>批量更新所有 git 仓库（git pull）</li>
            <li>批量切换分支</li>
        </ul>

        <h4>触发语句</h4>
        <ul>
            <li>批量更新：<code>帮我批量更新 git 库</code>、<code>update all git repos</code></li>
            <li>批量切换分支：<code>批量切换到 xxx 分支</code>、<code>switch all git repos to branch</code></li>
        </ul>

        <h4>使用方式</h4>
        <pre><code># 批量更新（默认当前目录）
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD"

# 批量更新指定目录
./plugins/git-multi-repo/scripts/git-multi-repo.sh /path/to/dir

# 批量切换分支
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD" branch-name</code></pre>

        <h2>添加新插件</h2>
        <p>参考 <code>plugins/git-multi-repo</code> 的结构：</p>
        <pre><code>plugins/&lt;plugin-name&gt;/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── &lt;plugin-name&gt;.md
└── scripts/
    └── &lt;plugin-name&gt;.sh</code></pre>
    </div>

    <div lang="en">
        <h1>Claude Plugins</h1>
        <p>A collection of custom Claude plugins for wishos.</p>

        <h2>Plugins</h2>

        <h3>git-multi-repo</h3>
        <p>A plugin for batch managing multiple git repositories.</p>

        <h4>Features</h4>
        <ul>
            <li>Batch update all git repositories (git pull)</li>
            <li>Batch switch branches</li>
        </ul>

        <h4>Trigger Phrases</h4>
        <ul>
            <li>Batch update: <code>帮我批量更新 git 库</code>, <code>update all git repos</code></li>
            <li>Batch switch branch: <code>批量切换到 xxx 分支</code>, <code>switch all git repos to branch</code></li>
        </ul>

        <h4>Usage</h4>
        <pre><code># Batch update (default: current directory)
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD"

# Batch update specified directory
./plugins/git-multi-repo/scripts/git-multi-repo.sh /path/to/dir

# Batch switch branch
./plugins/git-multi-repo/scripts/git-multi-repo.sh "$PWD" branch-name</code></pre>

        <h2>Adding a New Plugin</h2>
        <p>Refer to the structure of <code>plugins/git-multi-repo</code>:</p>
        <pre><code>plugins/&lt;plugin-name&gt;/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── &lt;plugin-name&gt;.md
└── scripts/
    └── &lt;plugin-name&gt;.sh</code></pre>
    </div>

    <script>
        function switchLang(lang) {
            document.querySelectorAll('[lang="zh"]').forEach(el => {
                el.style.display = lang === 'zh' ? 'block' : 'none';
            });
            document.querySelectorAll('[lang="en"]').forEach(el => {
                el.style.display = lang === 'en' ? 'block' : 'none';
            });
            document.getElementById('btn-zh').className = lang === 'zh' ? 'active' : '';
            document.getElementById('btn-en').className = lang === 'en' ? 'active' : '';
            document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en-US';
        }
    </script>
</body>
</html>
