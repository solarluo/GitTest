import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import duoxianc 1.0  // 保持原有模块名称

Window {
    width: 400
    height: 300
    visible: true
    title: "多线程示例"

    Worker {
        id: worker

        // 信号处理
        onResultReady: function(result) {
            resultText.text = result
        }

        onTimeElapsed: function(ms) {
            timerText.text = "已耗时: " + ms + " 毫秒"
        }

        onProgressChanged: function(percent) {
            // 直接更新自定义进度条
            progressFill.width = (percent / 100) * progressBg.width
            progressLabel.text = "进度: " + Math.round(percent) + "%"
        }

        onRunningChanged: function(running) {
            // 更新按钮状态
            startButton.enabled = !running
            stopButton.enabled = running

            // 更新状态指示器
            busyIndicator.color = running ? "green" : "gray"
            rotationAnimator.running = running

            // 更新进度条颜色
            progressFill.color = running ? "#534739" : "#CCA885"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // 自定义进度条（替代ProgressBar）
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            // 进度条容器
            Rectangle {
                id: progressContainer
                Layout.fillWidth: true
                height: 20
                radius: 3
                color: "yellow"

                // 进度背景（轨道）
                Rectangle {
                    id: progressBg
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"

                    // 进度填充
                    Rectangle {
                        id: progressFill
                        height: parent.height
                        width: 0
                        radius: parent.radius
                        //color: "gray"
                    }
                }
            }

            // 进度文本（单独显示在上方）
            Text {
                id: progressLabel
                Layout.alignment: Qt.AlignRight
                text: "进度: 0%"
                font.pixelSize: 12
                color: "#666"
            }
        }

        // 计时文本
        Text {
            id: timerText
            text: "等待开始..."
            font.pixelSize: 14
            color: "#666"
            Layout.fillWidth: true
        }

        // 结果文本
        Text {
            id: resultText
            text: "等待结果..."
            font.pixelSize: 16
            Layout.fillWidth: true
            Layout.topMargin: 10
        }

        // 按钮行
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15
            Layout.topMargin: 20

            Button {
                id: startButton
                text: "开始工作"
                enabled: true
                onClicked: {
                    // 重置UI状态
                    progressFill.width = 0
                    progressLabel.text = "进度: 0%"
                    timerText.text = "计时开始..."
                    resultText.text = "工作中..."

                    // 开始工作
                    worker.startWork()
                }
            }

            Button {
                id: stopButton
                text: "停止工作"
                enabled: false
                highlighted: true
                onClicked: {
                    // 停止工作
                    worker.stopWork()
                    resultText.text = "正在停止..."
                }
            }
        }

        // 状态指示器
        Rectangle {
            id: busyIndicator
            width: 30
            height: 30
            radius: 15
            color: "gray"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 15

            RotationAnimator {
                id: rotationAnimator
                target: busyIndicator
                from: 0
                to: 360
                duration: 1000
                running: false
                loops: Animation.Infinite
            }

            // 添加状态文本
            Text {
                anchors.centerIn: parent
                text: rotationAnimator.running ? "运行中" : "空闲"
                color: "white"
                font.pixelSize: 8
            }
        }
    }
}
