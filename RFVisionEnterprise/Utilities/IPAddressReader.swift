import Foundation

#if canImport(Darwin)
import Darwin
#endif

enum IPAddressReader {
    static func addresses() -> (ipv4: String?, ipv6: String?) {
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0, let first = list else { return (nil, nil) }
        defer { freeifaddrs(list) }

        var ipv4: String?
        var ipv6: String?
        var pointer: UnsafeMutablePointer<ifaddrs>? = first

        while let current = pointer {
            let item = current.pointee
            let flags = Int32(item.ifa_flags)
            let isUp = (flags & IFF_UP) == IFF_UP
            let isLoopback = (flags & IFF_LOOPBACK) == IFF_LOOPBACK
            if isUp, !isLoopback, let address = item.ifa_addr {
                let family = address.pointee.sa_family
                if family == UInt8(AF_INET) || family == UInt8(AF_INET6) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let length = socklen_t(address.pointee.sa_len)
                    if getnameinfo(address, length, &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        let value = String(cString: hostname)
                        if family == UInt8(AF_INET), ipv4 == nil { ipv4 = value }
                        if family == UInt8(AF_INET6), ipv6 == nil, !value.hasPrefix("fe80") { ipv6 = value }
                    }
                }
            }
            pointer = item.ifa_next
        }
        return (ipv4, ipv6)
    }
    static func ipv4Address() -> String? {
        addresses().ipv4
    }

    static func ipv6Address() -> String? {
        addresses().ipv6
    }

}
