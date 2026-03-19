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
  logo: "typst-img/1773924825701.png",
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
  
  // 优化代码块显示效果：添加背景色、圆角和边框
  show raw.where(block: true): it => block(
    fill: rgb("#f8f9fa"),
    inset: 12pt,
    radius: 6pt,
    stroke: 1pt + rgb("#dee2e6"),
    width: 100%,
    text(font: ("Consolas", "SimSun"), size: 10.5pt, it)
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

// === 下方为实际调用模板与正文编写示例 ===

#show: experiment-report.with(
  college: "化学化工学院",
  major: "化学",
  course: "物理化学实验",
  location: "化学楼D207",
  student-id: "2026123456",
  name: "张三",
  project: "从头算分子动力学(AIMD)模拟与动力学分析",
)

= 实验目的
掌握从头算分子动力学（AIMD）的基本原理。熟悉相关计算化学软件的输入文件结构及参数设置。学习处理模拟轨迹并提取相关动力学数据，分析化学反应过程。

= 实验原理
分子动力学方法通过牛顿运动方程追踪体系随时间的演化。与经典力场不同，从头算分子动力学在每个时间步通过求解电子结构实时获取原子受力，从而能够精确描述化学键的断裂与生成等过程。

= 实验结果与讨论
我们对计算生成的轨迹文件进行了能量演化分析。利用 Python 脚本提取了输出文件中的数据，并进行了可视化。

== 轨迹能量分析代码
以下是用于提取 AIMD 输出文件能量并绘制曲线的 Python 数据分析脚本示例：

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
  Typst 的 `columns` 函数可以极其优雅地在页面任意位置开启局部双栏排版。此处为左栏内容。这种布局方式非常适合在实验报告中进行对比说明，或者一侧放置参数说明，另一侧放置相关的公式或示意图。
  
  与全局设置双栏不同，此区块结束后，下方的文本会自动恢复为单栏宽幅排版，确保了版面规划的极高自由度。

  #colbreak()
  
  右侧移除了容易报错的外部宏包，改为直接利用 Typst 原生 `path` 函数绘制了一个示意图。
  
  #figure(
    box(width: 4.5cm, height: 3.5cm, {
      // Y 轴 (向上绘制)
      place(bottom + left, path(stroke: 1pt, (0cm, 0cm), (0cm, -3cm)))
      // X 轴 (向右绘制)
      place(bottom + left, path(stroke: 1pt, (0cm, 0cm), (4cm, 0cm)))
      
      // 坐标轴标签
      place(bottom + left, dx: 4.2cm, dy: 0.1cm, [$t$])
      place(bottom + left, dx: -0.2cm, dy: -3.2cm, [$E$])
      
      // 添加平衡线 (虚线)
      place(bottom + left, dy: -0.5cm, path(stroke: (dash: "dashed", paint: gray), (0cm, 0cm), (3.5cm, 0cm)))
      
      // 能量衰减曲线模拟 (折线模拟平滑曲线，杜绝包依赖报错)
      place(bottom + left, dy: -0.5cm, path(
        stroke: blue + 1.2pt,
        (0cm, -2cm), (0.4cm, -1.8cm), (0.8cm, -1.3cm), (1.2cm, -0.7cm), 
        (1.6cm, -0.3cm), (2.0cm, -0.1cm), (2.5cm, 0cm), (3.5cm, 0cm)
      ))
    }),
    caption: [基于 Typst 原生函数绘制的示意图]
  )
]

此处已恢复为普通的单栏排版。

== 实验数据可视化图表
此处展示基于上述脚本生成的系统状态或实验仪器的分布图。

#figure(
  image("typst-img/1773923994505.png", width: 60%, fit: "contain"),
  caption: [体系能量演化分布图示例]
)

从图中可以看出，体系在经历了大约 1000 个飞秒的弛豫后，总能量波动趋于平稳，说明体系已经达到了微正则系综下的热力学平衡状态。