import Foundation

extension String {
    /**
     Returns a localized version of the string, using the string itself as the key.
     
     - Parameter comment: An optional comment for translators.
     - Returns: The localized string from the app's strings files.
     */
    func local(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    /**
     Returns a localized and formatted string, using the string itself as the key.
     
     - Parameters:
       - arguments: The values to be formatted into the string.
       - comment: An optional comment for translators.
     - Returns: The localized and formatted string.
     */
    func local(with arguments: CVarArg..., comment: String = "") -> String {
        let localizedFormat = NSLocalizedString(self, comment: comment)
        return String(format: localizedFormat, arguments: arguments)
    }
}