#include "playlistmodel.h"
#include <QFileInfo>

PlaylistModel::PlaylistModel(QObject *parent) : QAbstractListModel(parent) {}

int PlaylistModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return m_items.count();
}

QVariant PlaylistModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_items.count()) return QVariant();

    const auto &item = m_items[index.row()];
    if (role == TitleRole) return item.title;
    if (role == UrlRole) return item.url;
    return QVariant();
}

QHash<int, QByteArray> PlaylistModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[UrlRole] = "url";
    return roles;
}

void PlaylistModel::addFile(const QUrl &url) {
    beginInsertRows(QModelIndex(), m_items.count(), m_items.count());
    QString path = url.isLocalFile() ? url.toLocalFile() : url.toString();
    m_items.append({QFileInfo(path).fileName(), url.toString()});
    endInsertRows();
    emit countChanged();

    if (m_currentIndex == -1) {
        setCurrentIndex(0);
    }
}

void PlaylistModel::addFiles(const QList<QUrl> &urls) {
    if (urls.isEmpty()) return;
    beginInsertRows(QModelIndex(), m_items.count(), m_items.count() + urls.count() - 1);
    for (const auto &url : urls) {
        QString path = url.isLocalFile() ? url.toLocalFile() : url.toString();
        m_items.append({QFileInfo(path).fileName(), url.toString()});
    }
    endInsertRows();
    emit countChanged();

    if (m_currentIndex == -1) {
        setCurrentIndex(0);
    }
}

void PlaylistModel::remove(int index) {
    if (index < 0 || index >= m_items.count()) return;
    beginRemoveRows(QModelIndex(), index, index);
    m_items.removeAt(index);
    endRemoveRows();
    emit countChanged();

    if (m_currentIndex >= m_items.count()) {
        setCurrentIndex(m_items.count() - 1);
    } else if (index == m_currentIndex) {
        setCurrentIndex(m_currentIndex); // Trigger reload
    }
}

void PlaylistModel::clear() {
    beginResetModel();
    m_items.clear();
    m_currentIndex = -1;
    endResetModel();
    emit countChanged();
    emit currentIndexChanged();
}

void PlaylistModel::setCurrentIndex(int index) {
    if (m_items.isEmpty()) {
        m_currentIndex = -1;
    } else {
        m_currentIndex = qBound(0, index, m_items.count() - 1);
        emit playbackRequested(m_items[m_currentIndex].url);
    }
    emit currentIndexChanged();
}

void PlaylistModel::next() {
    if (m_items.isEmpty()) return;
    setCurrentIndex((m_currentIndex + 1) % m_items.count());
}

void PlaylistModel::previous() {
    if (m_items.isEmpty()) return;
    setCurrentIndex((m_currentIndex - 1 + m_items.count()) % m_items.count());
}

QString PlaylistModel::currentUrl() const {
    if (m_currentIndex >= 0 && m_currentIndex < m_items.count()) {
        return m_items[m_currentIndex].url;
    }
    return QString();
}
