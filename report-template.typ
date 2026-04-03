/*
skills: 实验报告模板快速参考与严谨规范
description: |
  这是一个为实验报告量身定制的 Typst 模板底层库。
  此注释块是为了确保 AI 助手在生成代码时能够正确理解和调用模板的各项功能，并严格遵守排版与公式规范。
             |
```markdown
### 实验报告模板快速参考 (Skills)

#### 1. 作为库引入与正文编写格式 (防污染规范)
请在新建的正文 `.typ` 文档（如 `main.typ`）中引入本模板，绝不要直接在模板库文件中编写正文。正文文档的标准格式如下：

```typst
#import "report-template.typ": *

#show: experiment-report.with(
  college: "学院名称",
  major: "专业名称",
  course: "课程名称",
  location: "实验地点",
  // year: 2024, month: 10, day: 1, // 可选：指定特定日期，默认取系统当天日期
  // logo: "custom-logo.png",       // 可选：自定义左上角 Logo 图片路径
  student-id: "学号",
  name: "姓名",
  project: "实验项目名称"
)

= 实验目的
// 在此处编写实验目的...

= 实验原理
// 在此处编写实验原理...

= 实验结果与讨论
// 在此处编写实验结果与讨论，并使用下方列出的绘图函数...

= 结论
// 在此处编写实验结论...
```

#### 2. 数据分析与综合绘图
- **线性回归**: `#let reg = linear-regression(x, y)` 返回 `(k: 斜率, b: 截距, r2: 决定系数)`
- **综合与连续曲线绘图**:
  ```typst
  // 1. 绘制离散数据点并可叠加多种图层：
  #simple-line-plot(
    x-list, y-list, width: 10cm, height: 6.5cm,
    smooth: true,           // 开启 Catmull-Rom 平滑插值
    show-raw-line: true,    // 叠加原始折线 (灰色虚线)
    regression-data: reg,   // 叠加线性拟合线 (需先调用 linear-regression)
    curve-func: x => ...,   // 叠加自定义数学理论曲线
    bar-data: bar-list,     // 叠加底层直方图
    title: "图表标题",
    x-label: [浓度 ($"mol"\/"L"$)], // 注意转义单位的斜杠
    y-label: [吸光度 ($"A"$)]
  )
  
  // 2. 仅绘制纯数学理论连续曲线 (原 simple-curve-plot 功能)：
  #simple-line-plot(curve-func: x => calc.sin(x), curve-domain: (0, 10))
  ```

#### 3. 辅助组件与布局
- **侧边栏文本框**: `#question-box(title: "思考题")[内容]`
- **矩阵热图**: `#simple-heatmap(matrix)`
- **独立直方图**: `#simple-bar-chart(data)`
- **局部双栏排版**: `#columns(2)[ 左栏 #colbreak() 右栏 ]`

#### 4. 严谨公式与单位书写规范 (核心铁律)
- **必须转义斜杠**：在 Typst 的数学公式中书写单位符号时，必须使用 `\/` 对斜杠进行转义，以防止触发 Typst 的分数排版。示例：`$"mol"\/"L"$`、`$"g"\/"cm"^3$`。
- **双引号包裹纯文本/元素**：公式中的所有普通文本、物理单位符号、化学元素，**必须**使用双引号 `""` 包裹（例如 `$"mol"$`、`$"H"_2"O"$`、`$"A"$`），以防止被误解析为 Typst 的数学变量导致斜体或排版错误。
- **数学环境包裹**：所有的公式和单位都必须使用 `$...$` 包裹。
- **内容块 (Content Block)**：在代码模式下（例如调用函数传参时），若要传入包含纯文本、公式或排版指令的复合内容，必须使用方括号 `[...]` 将其包裹，以此从代码模式切换回排版模式（例如 `x-label: [浓度 ($"mol"\/"L"$)]`）。
- **禁止直接输入未转义的斜杠**：任何直接输入的斜杠 `/` 都会被 Typst 解析为分数线，导致排版错误。务必使用 `\/` 进行转义。
- **禁止输入{}用来书写公式**：Typst 的数学环境不使用 LaTeX 风格的花括号 `{}` 来分组或书写公式，请直接使用双引号 `""` 包裹文本和单位，并使用 `$...$` 包裹整个公式,使用括号`()`进行分组。示例：`$"n" = \frac{"m"}{"M"}$` 应写为 `$"n" = ("m")/("M")$`。对于指数和下标，也请使用括号包裹，例如 `$"H"_(2)"O"$`,`e^(-x/c)`。
```
*/

#import "@preview/cetz:0.3.2"
#import "@preview/cetz-plot:0.1.1": plot
#let my-info = toml("config.toml")
#let experiment-report(
  college: "",
  major: "",
  course: "",
  location: "",
  year: none,
  month: none,
  day: none,
  student-id: "",
  name: "",
  project: "",
  logo:none,
  body
) = {
  // 自动获取当前时间
  let current-datetime = datetime.today()
  let display-year = if year == none { str(current-datetime.year()) } else { str(year) }
  let display-month = if month == none { str(current-datetime.month()) } else { str(month) }
  let display-day = if day == none { str(current-datetime.day()) } else { str(day) }

  // 页面基础设置 (核心排版逻辑)
  set page(
    paper: "a4",
    // 精确锁定正文起始位置：2cm(顶端空隙) + 4.5cm(表头固定高度) = 6.5cm
    margin: (top: 5.5cm, bottom: 1cm, left: 1cm, right: 1cm),
    // 强制表头从距离页面顶部 0.4cm 处开始渲染
    header-ascent: 0.4cm,
    header: [
      #set text(font: ("Times New Roman", "SimSun"), size: 12pt, lang: "zh")
      // 锁定表头容器高度为 4.5cm，实现数学级别的绝对对齐
      #block(width: 100%, height: 4.5cm, {
        // 顶部三列布局：Logo、标题、右侧信息
        grid(
          // 左列设为 3.5cm，中列自适应填充，右列 7.5cm
          columns: (3.5cm, 1fr, 7.5cm),
          align: (center + horizon, center + horizon, left + horizon),
          
          // 1. Logo区域
          {
            let logo-size = 2.5cm
            if type(logo) == str {
              image(logo, width: logo-size)
            } else if logo != none {
              box(width: logo-size, logo)
            } else {
              circle(radius: 2cm, stroke: 1pt)[Logo]
            }
          },
          
          // 2. 主标题
          text(size: 29pt, weight: 800, font: ( "STZhongsong"), stroke: 0.2pt, tracking: 0.5em)[实验报告],
          
          // 3. 右上角信息栏
          {
            set text(size: 10pt)
            let field(label, content) = {
              grid(
                columns: (4.5em, 1fr),
                align: (left + bottom, left + bottom),
                label,
                box(width: 100%, stroke: (bottom: 0.5pt), inset: (bottom: 2pt), align(center, content))
              )
            }
            
            set block(spacing: 0.6em)
            field([学#h(2em)院], college)
            field([专#h(2em)业], major)
            field([实验课程], course)
            field([实验地点], location)
            
            // 日期特殊排版
            grid(
              columns: (4.5em, 1fr, auto, 1fr, auto, 1fr, auto),
              align: (left+bottom, center+bottom, center+bottom, center+bottom, center+bottom, center+bottom, center+bottom),
              [实验日期],
              box(width: 100%, stroke: (bottom: 0.5pt), inset: (bottom: 2pt), display-year), [年],
              box(width: 100%, stroke: (bottom: 0.5pt), inset: (bottom: 2pt), display-month), [月],
              box(width: 100%, stroke: (bottom: 0.5pt), inset: (bottom: 2pt), display-day), [日]
            )
          }
        )
        // 贯穿全宽的水平分割线
        line(length: 100%, stroke: 1.2pt)
        // 底部学生信息栏
        {
          set text(size: 11pt)
          grid(
            columns: (auto, 1fr, auto, 1fr, auto, 2.5fr),
            align: (left+bottom, center+bottom, left+bottom, center+bottom, left+bottom, center+bottom),
            [学号#h(0.5em)], box(width: 95%, stroke: (bottom: 0.5pt), inset: (bottom: 2pt), student-id),
            [姓名#h(0.5em)], box(width: 95%, stroke: (bottom: 0.5pt), inset: (bottom: 2pt), name),
            [实验项目#h(0.5em)], box(width: 100%, stroke: (bottom: 0.5pt), inset: (bottom: 2pt), project)
          )
        }
      })
    ]
  )

  // 默认字体设置 (支持中英文混排)，并设置语言为中文以本地化图表名称
  set text(font: ("Times New Roman", "SimSun"), size: 12pt, lang: "zh")

  // 开启标题自动编号
  set heading(numbering: "1.")
  
  // 优化代码块显示效果：添加背景色、圆角、边框以及右上角语言提示
  show raw.where(block: true): it => block(
    fill: rgb("#f8f9fa"),
    inset: 12pt,
    radius: 6pt,
    stroke: 1pt + rgb("#dee2e6"),
    width: 100%,
    {
      if it.lang != none {
        place(
          top + right,
          dx: 4pt,
          dy: -6pt,
          text(font: "Consolas", size: 10pt, fill: rgb("#6c757d"), weight: "bold", it.lang)
        )
      }
      text(font: ("Consolas", "SimSun"), size: 10.5pt, it)
    }
  )
  
  // 优化标题段前段后间距
  show heading: it => {
    v(0.1em)
    it
    v(0.1em)
  }

  // 正文排版设置：两端对齐，首行缩进两字符
  set par(justify: true, first-line-indent: 2em)
  body
}

// === 排版与绘图辅助函数定义区 ===

// 1. 独立文本框函数 (用于问题、思考、注意事项等)
#let question-box(title: "问题与思考", body) = {
  block(
    width: 100%,
    fill: rgb("#f4f8fa"),
    stroke: (left: 4pt + rgb("#0074d9")),
    inset: (x: 1.2em, y: 1em),
    radius: (right: 4pt),
    [
      #text(weight: "bold", fill: rgb("#0074d9"), size: 11pt)[#title]
      #v(0.6em, weak: true)
      #set text(size: 10.5pt, fill: rgb("#333333"))
      #body
    ]
  )
}

// 2. 简单线性回归计算函数
#let linear-regression(x-list, y-list) = {
  let n = x-list.len()
  let sum-x = x-list.sum()
  let sum-y = y-list.sum()
  let mean-x = sum-x / n
  let mean-y = sum-y / n
  
  let num = 0.0
  let den = 0.0
  let ss-tot = 0.0
  
  for i in range(n) {
    let dx = x-list.at(i) - mean-x
    let dy = y-list.at(i) - mean-y
    num = num + dx * dy
    den = den + dx * dx
    ss-tot = ss-tot + dy * dy
  }
  
  let k = if den != 0 { num / den } else { 0 }
  let b = mean-y - k * mean-x
  
  let ss-res = 0.0
  for i in range(n) {
    let y-pred = k * x-list.at(i) + b
    let dy-res = y-list.at(i) - y-pred
    ss-res = ss-res + dy-res * dy-res
  }
  
  let r-squared = if ss-tot != 0 { 1.0 - (ss-res / ss-tot) } else { 0 }
  
  return (k: k, b: b, r2: r-squared)
}

// 2.5 自动插值算法：Catmull-Rom 样条平滑插值函数 (将离散数组转化为连续平滑函数)
#let spline-interpolate(x-list, y-list, x) = {
  let n = x-list.len()
  if x <= x-list.at(0) { return y-list.at(0) }
  if x >= x-list.at(n - 1) { return y-list.at(n - 1) }

  let i = 0
  while i < n - 1 and x > x-list.at(i + 1) {
    i += 1
  }

  let x0 = if i > 0 { x-list.at(i - 1) } else { x-list.at(0) - (x-list.at(1) - x-list.at(0)) }
  let y0 = if i > 0 { y-list.at(i - 1) } else { y-list.at(0) - (y-list.at(1) - y-list.at(0)) }

  let x1 = x-list.at(i)
  let y1 = y-list.at(i)

  let x2 = x-list.at(i + 1)
  let y2 = y-list.at(i + 1)

  let x3 = if i < n - 2 { x-list.at(i + 2) } else { x-list.at(n - 1) + (x-list.at(n - 1) - x-list.at(n - 2)) }
  let y3 = if i < n - 2 { y-list.at(i + 2) } else { y-list.at(n - 1) + (y-list.at(n - 1) - y-list.at(n - 2)) }

  let t = if x2 != x1 { (x - x1) / (x2 - x1) } else { 0 }
  let t2 = t * t
  let t3 = t2 * t

  let c0 = y1
  let c1 = 0.5 * (y2 - y0)
  let c2 = y0 - 2.5 * y1 + 2.0 * y2 - 0.5 * y3
  let c3 = -0.5 * y0 + 1.5 * y1 - 1.5 * y2 + 0.5 * y3

  return c0 + c1 * t + c2 * t2 + c3 * t3
}

// 3. 折线图与多重综合绘图函数 (已终极进化：整合纯曲线绘制，支持散点、折线、平滑曲线、拟合线、数学曲线以及底层直方图混合渲染)
#let simple-line-plot(
  ..data, // 支持动态接收位置参数 x-list 和 y-list，或完全省略以纯曲线模式渲染
  width: 10cm, height: 6.5cm, 
  show-points: true, 
  smooth: false,         // 自动插值平滑开关
  show-raw-line: false,  // 是否同时显示原始相连折线
  regression-data: none,
  curve-func: none,      // 传入连续函数，用于叠加或单独展现曲线图
  curve-domain: none,    // 连续函数的定义域区间
  bar-data: none,        // 用于在底部叠加的直方图数据
  title: none,
  x-label: none,
  y-label: none
) = {
  let pos = data.pos()
  let x-list = none
  let y-list = none
  if pos.len() >= 2 {
    x-list = pos.at(0)
    y-list = pos.at(1)
  }

  let w = width / 1cm
  let h = height / 1cm
  
  align(center, cetz.canvas({
    import cetz.draw: *

    plot.plot(
      size: (w, h),
      x-label: if x-label != none { text(size: 9pt)[#x-label] } else { none },
      y-label: if y-label != none { text(size: 9pt)[#y-label] } else { none },
      {
        if x-list != none and y-list != none {
          let plot-data = array.zip(x-list, y-list)
          
          // 核心渲染层级控制：1. 最底层渲染直方图，防止遮挡任何上层线型
          if bar-data != none {
            let b-data = ()
            let limit = calc.min(x-list.len(), bar-data.len())
            for i in range(limit) {
              b-data.push((x-list.at(i), bar-data.at(i)))
            }
            // 采用较浅的颜色渲染底部直方图，以免喧宾夺主
            plot.add-bar(b-data, style: (fill: rgb(176, 196, 222), stroke: 0.5pt + rgb("#203554")))
          }

          // 2. 倒数第二层：原始连接折线
          if smooth {
            let x-min = calc.min(..x-list)
            let x-max = calc.max(..x-list)
            
            if show-raw-line {
              plot.add(plot-data, style: (stroke: (paint: gray, dash: "dashed", thickness: 1pt)))
            }

            // 3. 中间层：平滑插值曲线
            plot.add(
              domain: (x-min, x-max),
              x => spline-interpolate(x-list, y-list, x),
              style: (stroke: blue + 1.2pt)
            )
            // 4. 上层：数据散点
            if show-points {
              plot.add(plot-data, mark: "o", style: (stroke: none), mark-style: (fill: red, stroke: none))
            }
          } else {
            // 常规折线渲染逻辑
            if show-points {
              plot.add(plot-data, mark: "o", style: (stroke: blue + 1.2pt), mark-style: (fill: red, stroke: none))
            } else {
              plot.add(plot-data, style: (stroke: blue + 1.2pt))
            }
          }

          // 5. 顶层叠加逻辑：线性回归线
          if regression-data != none {
            let x-min = calc.min(..x-list)
            let x-max = calc.max(..x-list)
            let y-pred-start = regression-data.k * x-min + regression-data.b
            let y-pred-end = regression-data.k * x-max + regression-data.b
            plot.add(
              ((x-min, y-pred-start), (x-max, y-pred-end)),
              style: (stroke: (paint: green, dash: "dashed", thickness: 1pt))
            )
          }

          // 6. 顶层叠加逻辑：数学连续函数理论曲线
          if curve-func != none {
            let domain = if curve-domain != none { curve-domain } else { (calc.min(..x-list), calc.max(..x-list)) }
            plot.add(
              domain: domain,
              curve-func,
              style: (stroke: rgb("#ff7f0e") + 1.5pt)
            )
          }
        } else {
          // 纯数学曲线渲染模式（无需传入离散数据）
          if curve-func != none {
            let domain = if curve-domain != none { curve-domain } else { (0, 10) }
            plot.add(
              domain: domain,
              curve-func,
              style: (stroke: blue + 1.2pt)
            )
          }
        }
      }
    )

    if title != none {
      content((w / 2, h + 0.5), text(weight: "bold", size: 10.5pt)[#title])
    }

    if regression-data != none and x-list != none {
      let sign = if regression-data.b >= 0 { "+" } else { "" }
      let eq-text = [
        $y = #calc.round(regression-data.k, digits: 3) x #sign #calc.round(regression-data.b, digits: 3)$\
        $R^2 = #calc.round(regression-data.r2, digits: 4)$
      ]
      content((w * 0.25, h - 0.5), block(fill: rgb(255, 255, 255, 200), stroke: 0.5pt + luma(180), inset: 6pt, radius: 2pt, text(size: 8pt)[#eq-text]))
    }
  }))
}

// 4. 直方图/柱状图绘制函数 (所有函数均已对外暴露宽度和高度设置)
#let simple-bar-chart(data-list, width: 8cm, height: 5cm) = {
  let w = width / 1cm
  let h = height / 1cm
  let bar-data = ()
  
  for i in range(data-list.len()) {
    bar-data.push((i + 1, data-list.at(i)))
  }

  align(center, cetz.canvas({
    import cetz.draw: *
    plot.plot(
      size: (w, h),
      x-tick-step: 1,
      {
        plot.add-bar(bar-data, style: (fill: rgb("#4c72b0"), stroke: 0.5pt + rgb("#203554")))
      }
    )
  }))
}

// 5. 多维列表热图渲染函数
#let simple-heatmap(matrix, cell-size: 20pt) = {
  let rows = matrix.len()
  let cols = matrix.at(0).len()
  let flat-data = matrix.flatten()
  let min-val = calc.min(..flat-data)
  let max-val = calc.max(..flat-data)
  let range-val = if max-val != min-val { max-val - min-val } else { 1.0 }
  let c-size = cell-size / 1cm
  
  align(center, cetz.canvas({
    import cetz.draw: *
    for r in range(rows) {
      for c in range(cols) {
        let val = matrix.at(r).at(c)
        let intensity = (val - min-val) / range-val
        
        let gb = 255 - int(intensity * 255)
        let cell-color = rgb(255, gb, gb)
        
        let x = c * c-size
        let y = (rows - r - 1) * c-size
        
        rect((x, y), (x + c-size, y + c-size), fill: cell-color, stroke: 0.5pt + luma(200))
        content((x + c-size / 2, y + c-size / 2), text(size: 8pt, fill: if intensity > 0.6 { white } else { black })[#calc.round(val, digits: 2)])
      }
    }
  }))
}
// === 下方为实际调用模板与正文编写示例 ===
#show: experiment-report.with(
  college: my-info.college,
  major: my-info.major,
  student-id: my-info.student-id,
  name: my-info.name,
  course: "物理化学实验",
  location: "化学楼D207",
  project: "从头算分子动力学模拟"
)

= 将你的个人信息（学院、专业、学号、姓名）填写在 `config.toml` 文件中，确保它们能够被正确读取并显示在报告的表头和学生信息栏中。


= toml 文件示例内容：
```toml
name = "张三"
student-id = "2026123456"
college = "化学化工学院"
major = "化学"
```

= 实验结果与讨论
我们对计算生成的轨迹文件进行了能量演化分析。利用 Python 脚本提取了输出文件中的数据，并进行了可视化。

== 轨迹能量分析代码
以下是用于提取 AIMD 输出文件能量并绘制曲线的 Python 数据分析脚本示例：
````typst
= 实验目的
掌握从头算分子动力学（AIMD）的基本原理。熟悉相关计算化学软件的输入文件结构及参数设置。学习处理模拟轨迹并提取相关动力学数据，分析化学反应过程。
```python
import numpy as np
```
````
```python
import numpy as np
import matplotlib.pyplot as plt
# 提取能量演化数据
def plot_energy(filename):
    data = np.loadtxt(filename, comments="#")
    time_fs = data[:, 0]
    total_energy = data[:, 1]
    plt.figure(figsize=(8, 5))
    plt.plot(time_fs, total_energy, label="Total Energy", color="navy", linewidth=1.5)
    plt.xlabel("Simulation Time (fs)")
    plt.ylabel("Energy (a.u.)")
    plt.title("AIMD Energy Evolution")
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.show()
# 执行可视化
plot_energy("aimd_energetics.dat")
```

#pagebreak()
== 局部双栏与原生绘图测试

#columns(2)[
  Typst 的 `columns` 函数可以极其优雅地在页面任意位置开启局部双栏排版。
  与全局设置双栏不同，此区块结束后，下方的文本会自动恢复为单栏宽幅排版，确保了版面规划的极高自由度。
  #colbreak()
  这是右栏内容。您可以在这里放置与左栏内容相关的图表、代码块或者补充说明。双栏布局的好处在于能够在视觉上形成对照，增强读者的理解和记忆效果。
]
```typst
#columns(2)[
  Typst 的 `columns` 函数可以极其优雅地在页面任意位置开启局部双栏排版。此处为左栏内容。这种布局方式非常适合在实验报告中进行对比说明，或者一侧放置参数说明，另一侧放置相关的公式或示意图。
  与全局设置双栏不同，此区块结束后，下方的文本会自动恢复为单栏宽幅排版，确保了版面规划的极高自由度。
  #colbreak()
  这是右栏内容。您可以在这里放置与左栏内容相关的图表、代码块或者补充说明。双栏布局的好处在于能够在视觉上形成对照，增强读者的理解和记忆效果。]
```

*此处已恢复为普通的单栏排版。*

== 实验数据可视化图表
#figure(
  image("assets\\image.png", width: 56%, fit: "contain"),
  caption: [示例]
)
```typst
#figure(
  image("assets\\image.png", width: 56%, fit: "contain"),
  caption: [示例]
)
```
== 原生辅助函数调用示例
#question-box(title: "实验思考题")[在AIMD模拟中，为什么体系的初始构型通常需要先进行经典的分子力学几何优化？]
```typst
#question-box(title: "实验思考题")[在AIMD模拟中，为什么体系的初始构型通常需要先进行经典的分子力学几何优化？]
```
#pagebreak()
#let x-data = (1.0, 2.0, 3.0, 4.0, 5.0)
#let y-data = (2.1, 3.9, 6.2, 7.8, 10.1)
#let reg-result = linear-regression(x-data, y-data)

我们输入了简单的两组数据进行线性拟合，计算得到斜率 $k =$ #calc.round(reg-result.k, digits: 3)，截距 $b =$ #calc.round(reg-result.b, digits: 3)，决定系数 $R^2 =$ #calc.round(reg-result.r2, digits: 4)。
```typst
#let x-data = (1.0, 2.0, 3.0, 4.0, 5.0)
#let y-data = (2.1, 3.9, 6.2, 7.8, 10.1)
#let reg-result = linear-regression(x-data, y-data)
```
#figure(
  simple-line-plot(
    x-data, y-data, 
    regression-data: reg-result,
    title: "浓度与吸光度标准曲线",
    x-label: [浓度 ($"mol"\/"L"$)],
    y-label: [吸光度 ($"A"$)]
    ,width:400pt,height: 9cm
  ),
  caption: [增加了标题、坐标轴标签与拟合公式的折线图]
)
```typst
#figure(
  simple-line-plot(
    x-data, y-data, 
    regression-data: reg-result,
    title: "浓度与吸光度标准曲线",
    x-label: [浓度 ($"mol"\/"L"$)],
    y-label: [吸光度 ($"A"$)]
  ),
  caption: [增加了标题、坐标轴标签与拟合公式的折线图]
)
```
#pagebreak()
== 双栏排版多图并列与多曲线叠加展示测试
利用 Typst 的 grid 布局配合图形函数的宽度压缩（调至8cm），可以实现非常紧凑严密的对照分析效果。同时，您可以在同一张图中传入额外的平滑理论曲线。

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  figure(
    simple-line-plot(
      x-data, y-data, 
      width: 8cm, height: 5cm,
      regression-data: reg-result,
      title: "数据点与线性拟合",
      x-label: [坐标 ($"x"$)],
      y-label: [坐标 ($"y"$)]
    ),
    caption: [单栏自适应尺寸测试]
  ),
  figure(
    simple-line-plot(
      x-data, y-data, 
      width: 8cm, height: 5cm,
      regression-data: reg-result,
      // 在已有散点和拟合线基础上，额外注入抛物线曲线函数
      curve-func: x => calc.pow(x, 1.2) + 1.0,
      title: "数据点+拟合+预期理论曲线",
      x-label: [坐标 ($"x"$)],
      y-label: [坐标 ($"y"$)]
    ),
    caption: [同图表三种形式的数学混合渲染]))
```typst
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  figure(
    simple-line-plot(
      x-data, y-data, 
      width: 8cm, height: 5cm,
      regression-data: reg-result,
      title: "数据点与线性拟合",
      x-label: [坐标 ($"x"$)],
      y-label: [坐标 ($"y"$)]
    ),
    caption: [单栏自适应尺寸测试]
  ),
  figure(
    simple-line-plot(
      x-data, y-data, 
      width: 8cm, height: 5cm,
      regression-data: reg-result,
      // 在已有散点和拟合线基础上，额外注入抛物线曲线函数
      curve-func: x => calc.pow(x, 1.2) + 1.0,
      title: "数据点+拟合+预期理论曲线",
      x-label: [坐标 ($"x"$)],
      y-label: [坐标 ($"y"$)]
    ),
    caption: [同图表三种形式的数学混合渲染]))
```

== 数组自动平滑插值功能测试
使用全新的 `smooth: true` 开关进行自动插值。如果需要对照散点的偏离程度，开启 `show-raw-line: true` 即可渲染出重叠效果。

#let smooth-x-data = (1.0, 2.5, 4.0, 5.5, 7.0, 8.5)
#let smooth-y-data = (1.5, 4.2, 3.1, 6.8, 5.2, 8.9)

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  figure(
    simple-line-plot(
      smooth-x-data, smooth-y-data, 
      smooth: true,
      width: 8cm, height: 5cm,
      title: "仅显示平滑插值曲线",
      x-label: [时间 ($"s"$)],
      y-label: [电压 ($"mV"$)]
    ),
    caption: [纯粹的平滑插值渲染]
  ),
  figure(
    simple-line-plot(
      smooth-x-data, smooth-y-data, 
      smooth: true,
      show-raw-line: true, // 开启此项，叠加灰色虚线连接数据点
      width: 8cm, height: 5cm,
      title: "平滑插值与原始折线对比",
      x-label: [时间 ($"s"$)],
      y-label: [电压 ($"mV"$)]
    ),
    caption: [同时渲染平滑曲线和数据点折线]
  )
)
```typst
#let smooth-x-data = (1.0, 2.5, 4.0, 5.5, 7.0, 8.5)
#let smooth-y-data = (1.5, 4.2, 3.1, 6.8, 5.2, 8.9)

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  figure(
    simple-line-plot(
      smooth-x-data, smooth-y-data, 
      smooth: true,
      width: 8cm, height: 5cm,
      title: "仅显示平滑插值曲线",
      x-label: [时间 ($"s"$)],
      y-label: [电压 ($"mV"$)]),
    caption: [纯粹的平滑插值渲染]),
  figure(
    simple-line-plot(
      smooth-x-data, smooth-y-data, 
      smooth: true,
      show-raw-line: true, // 开启此项，叠加灰色虚线连接数据点
      width: 8cm, height: 5cm,
      title: "平滑插值与原始折线对比",
      x-label: [时间 ($"s"$)],
      y-label: [电压 ($"mV"$)]
    ),
    caption: [同时渲染平滑曲线和数据点折线]))
```
#figure(
  simple-bar-chart((15, 30, 45, 20, 10, 55)),
  caption: [直方图分布测试]
)
```typst
#figure(
  simple-bar-chart((15, 30, 45, 20, 10, 55)),
  caption: [直方图分布测试]
)
```
#let heat-data = (
  (0.1, 0.5, 0.8, 0.2),
  (0.3, 0.9, 1.0, 0.4),
  (0.2, 0.6, 0.7, 0.1)
)

#figure(
  simple-heatmap(heat-data),
  caption: [基于二维列表的热图渲染]

)
```typst
#let heat-data = (
  (0.1, 0.5, 0.8, 0.2),
  (0.3, 0.9, 1.0, 0.4),
  (0.2, 0.6, 0.7, 0.1)
)
#figure(
  simple-heatmap(heat-data),
  caption: [基于二维列表的热图渲染]
)
```
#figure(
  simple-line-plot(
    curve-func: x => calc.sin(x * 1.5) * 3 + 5, 
    curve-domain: (0, 6.28),
    title: "平滑数学函数曲线图测试",
    x-label: [反应时间 ($"s"$)],
    y-label: [体系能量 ($"a.u."$)]
  ),
  caption: [基于新增数学函数方法渲染的平滑曲线图]
)
```typst
#figure(
  simple-line-plot(
    curve-func: x => calc.sin(x * 1.5) * 3 + 5, 
    curve-domain: (0, 6.28),
    title: "平滑数学函数曲线图测试",
    x-label: [反应时间 ($"s"$)],
    y-label: [体系能量 ($"a.u."$)]
  ),
  caption: [基于新增数学函数方法渲染的平滑曲线图]
)
```
#pagebreak()
== 全能综合图表叠加测试
在这个测试用例中，我们演示了通过一次函数调用，在同一图表中将直方图（自动置于最底层防遮挡）、离散数据点、原始折线、Catmull-Rom平滑插值曲线、线性拟合回归线，以及纯数学理论曲线进行毫无违和感的全方位叠加。

#let comp-x = (1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
#let comp-y = (2.5, 4.1, 3.5, 6.0, 5.2, 8.5)
#let comp-bar = (1.5, 3.0, 2.5, 4.5, 4.0, 7.0)
#let comp-reg = linear-regression(comp-x, comp-y)

#figure(
  simple-line-plot(
    comp-x, comp-y,
    width: 12cm, height: 7cm,
    smooth: true,
    show-raw-line: true,
    bar-data: comp-bar,
    regression-data: comp-reg,
    curve-func: x => calc.sin(x * 2.0) * 1.5 + 4.5,
    title: "全能综合信号分析叠加图",
    x-label: [观测点位 ($"x"$)],
    y-label: [综合响应强度 ($"I"$)]
  ),
  caption: [在一张图中同时无损重叠渲染直方图、散点、折线、平滑曲线、线性拟合及数学理论函数]
)
```typst
#let comp-x = (1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
#let comp-y = (2.5, 4.1, 3.5, 6.0, 5.2, 8.5)
#let comp-bar = (1.5, 3.0, 2.5, 4.5, 4.0, 7.0)
#let comp-reg = linear-regression(comp-x, comp-y)

#figure(
  simple-line-plot(
    comp-x, comp-y,
    width: 12cm, height: 7cm,
    smooth: true,
    show-raw-line: true,
    bar-data: comp-bar,
    regression-data: comp-reg,
    curve-func: x => calc.sin(x * 2.0) * 1.5 + 4.5,
    title: "全能综合信号分析叠加图",
    x-label: [观测点位 ($"x"$)],
    y-label: [综合响应强度 ($"I"$)]
  ),
  caption: [在一张图中同时无损重叠渲染直方图、散点、折线、平滑曲线、线性拟合及数学理论函数]
)
```