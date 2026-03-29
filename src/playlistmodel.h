#pragma once

#include <QAbstractListModel>
#include <QStringList>
#include <QUrl>

struct PlaylistItem {
    QString title;
    QString url;
};

class PlaylistModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        UrlRole
    };

    explicit PlaylistModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addFile(const QUrl &url);
    Q_INVOKABLE void addFiles(const QList<QUrl> &urls);
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();

    int currentIndex() const { return m_currentIndex; }
    void setCurrentIndex(int index);

    int count() const { return m_items.count(); }
    QString currentUrl() const;

signals:
    void currentIndexChanged();
    void countChanged();
    void playbackRequested(const QString &url);

private:
    QList<PlaylistItem> m_items;
    int m_currentIndex = -1;
};
