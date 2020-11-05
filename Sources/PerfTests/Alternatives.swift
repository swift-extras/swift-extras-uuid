import ExtrasUUID

#if canImport(Darwin)
import Darwin

extension XUUID {
    static func fromUUIDStringUsingUUIDParse(_ string: String) -> XUUID? {
        // This is the base implementation... I guess this is what is done for
        // Foundation.UUID
        let _uuid = string.withCString { (cString) -> uuid_t? in
            var _uuid: xuuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            guard uuid_parse(cString, &_uuid.0) == 0 else {
                return nil
            }

            return _uuid
        }

        guard let uuid = _uuid else {
            return nil
        }

        return Self(uuid: uuid)
    }

    func lowercasedUsingUUID() -> String {
        var value: xuuid_t = self.uuid
        let target = UnsafeMutablePointer<Int8>.allocate(capacity: 37)
        uuid_unparse_lower(&value.0, target)
        return String(cString: target)
    }
}
#endif
