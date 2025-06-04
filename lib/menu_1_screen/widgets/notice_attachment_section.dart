import 'package:flutter/material.dart';
import 'package:hoseo_m_client/models/notice_models.dart';
import 'package:hoseo_m_client/utils/notice_file_utils.dart';
import 'package:hoseo_m_client/menu_1_screen/widgets/notice_download_indicators.dart';

class NoticeAttachmentSection extends StatelessWidget {
  final List<NoticeAttachmentItem> attachments;
  final Map<String, double> downloadProgress;
  final bool isConnected;
  final Function(NoticeAttachmentItem) onUserDownload;

  const NoticeAttachmentSection({
    super.key,
    required this.attachments,
    required this.downloadProgress,
    required this.isConnected,
    required this.onUserDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context), _buildAttachmentsList()],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.attach_file, size: 20),
          const SizedBox(width: 8),
          Text(
            '첨부파일 (${attachments.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (!isConnected) ...[
            const SizedBox(width: 8),
            Text('(오프라인)', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsList() {
    return Container(
      constraints: BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: attachments.length,
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return _buildAttachmentItem(attachment);
        },
      ),
    );
  }

  Widget _buildAttachmentItem(NoticeAttachmentItem attachment) {
    final progress = downloadProgress[attachment.originName];
    final isDownloading = progress != null;

    return ListTile(
      leading: _buildAttachmentIcon(attachment.originName),
      title: Text(attachment.originName, style: TextStyle(fontSize: 14, color: isConnected ? null : Colors.grey)),
      subtitle: _buildSubtitle(attachment),
      trailing: _buildTrailing(attachment, isDownloading, progress),
      onTap: isConnected && !isDownloading ? () => onUserDownload(attachment) : null,
    );
  }

  Widget _buildAttachmentIcon(String fileName) {
    return Icon(NoticeFileUtils.getFileIcon(fileName), color: NoticeFileUtils.getFileColor(fileName), size: 32);
  }

  Widget _buildSubtitle(NoticeAttachmentItem attachment) {
    return Row(children: [if (attachment.fileSize != null) Text(NoticeFileUtils.formatFileSize(attachment.fileSize!))]);
  }

  Widget _buildTrailing(NoticeAttachmentItem attachment, bool isDownloading, double? progress) {
    if (isDownloading && progress != null) {
      return NoticeDownloadIndicators.buildAttachmentDownloadProgress(progress);
    }

    return IconButton(
      icon: Icon(Icons.download, color: isConnected ? null : Colors.grey),
      onPressed: isConnected ? () => onUserDownload(attachment) : null,
    );
  }
}
