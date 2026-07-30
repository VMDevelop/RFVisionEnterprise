import SwiftUI

#if os(iOS)
import UIKit
struct ShareFileView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: [url], applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
struct ShareFileView: View { let url: URL; var body: some View { Text(url.path).textSelection(.enabled) } }
#endif
