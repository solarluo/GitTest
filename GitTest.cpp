#include "GitTest.h"

// Worker 类实现
Worker::Worker(QObject* parent) : QObject(parent) {}

Worker::~Worker() {
    stopWork();
}

bool Worker::isRunning() const {
    QMutexLocker locker(&m_mutex); // 现在可以安全使用
    return m_running;
}

void Worker::startWork() {
    QMutexLocker locker(&m_mutex);
    if (m_running) return;

    m_running = true;
    emit runningChanged(true);

    // 创建新线程
    m_currentThread = new WorkerThread(&m_mutex);

    // 连接信号
    connect(m_currentThread, &WorkerThread::progressUpdate, this, &Worker::progressChanged);
    connect(m_currentThread, &WorkerThread::workDone, this, [this](int elapsedMs) {
        WorkerThread* threadToDelete = nullptr;

        {
            QMutexLocker locker(&m_mutex);
            if (!m_running) return;

            m_running = false;
            threadToDelete = m_currentThread;
            m_currentThread = nullptr;
        }

        emit runningChanged(false);
        emit timeElapsed(elapsedMs);
        emit resultReady(QString("工作完成! 耗时: %1 毫秒").arg(elapsedMs));

        if (threadToDelete) {
            threadToDelete->deleteLater();
        }
    });

    // 启动线程
    m_currentThread->start();asd
}

void Worker::stopWork() {
    WorkerThread* threadToStop = nullptr;

    {
        QMutexLocker locker(&m_mutex);
        if (!m_running || !m_currentThread) return;

        // 请求线程停止
        m_currentThread->requestStop();

        // 更新状态
        m_running = false;
        emit runningChanged(false);
        emit resultReady("工作已停止");

        // 保存线程指针以便稍后清理
        threadToStop = m_currentThread;
        m_currentThread = nullptr;
    }

    // 等待线程结束（不持有锁）
    if (threadToStop && threadToStop->isRunning()) {
        threadToStop->wait(500);
    }

    // 清理线程
    if (threadToStop) {
        threadToStop->deleteLater();
    }
}

// WorkerThread 类实现
WorkerThread::~WorkerThread() {
    if (isRunning()) {
        requestStop();
        wait(500);
    }
}

void WorkerThread::run() {
    QElapsedTimer timer;
    timer.start();

    const int totalSteps = 10;
    int sleepTime = 1000 + QRandomGenerator::global()->bounded(2000);

    for (int i = 1; i <= totalSteps; i++) {
        // 检查停止请求
        {
            QMutexLocker locker(m_mutex);
            if (m_stopRequested) {
                emit workDone(timer.elapsed());
                return;
            }
        }

        // 更新进度
        int percent = i * 100 / totalSteps;
        emit progressUpdate(percent);

        // 模拟工作步骤
        QThread::msleep(sleepTime / totalSteps);
    }

    emit workDone(timer.elapsed());
}

void WorkerThread::requestStop() {
    QMutexLocker locker(m_mutex);
    m_stopRequested = true;
}
