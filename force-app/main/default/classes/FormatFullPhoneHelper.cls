public class FormatFullPhoneHelper {
        
    public static String processPhoneNumber(String DDI, String phone, String locale){
        
        if (phone == null) return null;
        
        Boolean needsToFormat = true;
        
        String fullPhone = preparePhoneNumberForFormatting(DDI, phone);
        
        if (fullPhone == null || !fullPhone.isNumeric()) return null;
                        
        if (fullPhone != null && fullPhone.startsWith('+') && !fullPhone.startsWith('+55')) needsToFormat = false;
                
        if (needsToFormat){
            fullPhone = formatPhoneNumberByLocale(fullPhone, locale);
            
            if (fullPhone == null) return null;
        }       
        
        return fullPhone;
    }
    
    private static String preparePhoneNumberForFormatting(String DDI, String phone){
                        
        String fullPhone = DDI != null ? DDI + phone : phone;
        
        fullPhone = Utils.removeSpecialCharacters(fullPhone);
        return String.valueOf(fullPhone).escapeHtml3().escapeHtml4().escapeUnicode().escapeXML().escapeCSV();        
    }  
    
    private static String formatPhoneNumberByLocale(String phone, String locale){
        
        String fullPhoneToReturn = null;
        
        if (locale == 'BR' || locale == null){
            fullPhoneToReturn = formatLocale_BR(phone);
            if (fullPhoneToReturn != null) return fullPhoneToReturn;            
        }
        
        else if (locale == 'AR'){
            fullPhoneToReturn = formatLocale_AR(phone);
            if (fullPhoneToReturn != null) return fullPhoneToReturn;            
        }
        
        else if (locale == 'CO'){
            fullPhoneToReturn = formatLocale_CO(phone);
            if (fullPhoneToReturn != null) return fullPhoneToReturn;            
        }
        
        else if (locale == 'MX'){
            fullPhoneToReturn = formatLocale_MX(phone);
            if (fullPhoneToReturn != null) return fullPhoneToReturn;            
        }
        
        else if (locale == 'US'){
            fullPhoneToReturn = formatLocale_US(phone);
            if (fullPhoneToReturn != null) return fullPhoneToReturn;            
        }
        
        else if (locale == 'PE'){
            fullPhoneToReturn = formatLocale_PE(phone);
            if (fullPhoneToReturn != null) return fullPhoneToReturn;            
        }
        
        else if (locale == 'ES'){
            fullPhoneToReturn = formatLocale_ES(phone);
            if (fullPhoneToReturn != null) return fullPhoneToReturn;            
        }
        
        return null;
    }
    
    private static String formatLocale_BR(String phone){
        
        if (phone.length() == 13 && (!phone.startsWith('55') || phone.indexOf('550') == 0 || phone.charAt(4) != 57) ) //57 is the value of string number '9'
            return null;
        
        if (phone.length() == 13 && phone.startsWith('55') && phone.indexOf('550') != 0 && phone.charAt(4) == 57 ) //in this example, its all correct
            return phone;
        
        if (phone.length() == 10) //exemplo 1144445555, add 55 and 9
            return '55' + phone.left(2) + '9' + phone.right(8);
        
        else if (phone.length() == 11 && phone.startsWith('0')) //01144445555, add 55 and remove 0
           return '55' + phone.left(3).right(2) + '9' + phone.right(8);
        
        else if (phone.length() == 11 && !phone.startsWith('0')) //11944445555, add 55
            return '55' + phone;
        
        else if (phone.length() == 15)
            return phone.right(13);
        
        else if (phone.length() == 14 && phone.indexOf('550') == 0) //55011944445555, remove 0 from DDD
            return '55' + phone.substring(3);
        
        else if (phone.length() == 12) // 551144445555, add 9 
            return phone.left(4) + '9' + phone.right(8);
        
        else
            return null;
    }
    
    private static String formatLocale_AR(String phone){
                
        if (phone.length() == 13 && (phone.startsWith('54') || phone.indexOf('549') == 0) ) //5491123456789
            return phone;
        
        if (phone.length() == 12 && phone.startsWith('54')) //541123456789, add 9
            return phone.left(2) + '9' + phone.right(10);
        
        if (phone.length() == 15 && phone.right(13).startsWith('54')) //005491123456789
            return phone.right(13);
        
        else
            return null;
    }
    
    private static String formatLocale_CO(String phone){
        
        if (phone.length() == 12 && (phone.startsWith('57'))) //571112345678
            return phone;
        
        if (phone.length() == 14 && phone.right(12).startsWith('57')) //00571112345678, remove 00
            return phone.right(12);
        
        else
            return null;
    }
    
    private static String formatLocale_MX(String phone){
        
        if (phone.length() == 13 && phone.startsWith('52') && phone.indexOf('551') != 0) //5211234567890
            return phone;
        
        if (phone.length() == 12 && phone.startsWith('52')) //52 1234567890, add 1
            return phone.left(2) + '1' + phone.right(10);
        
        if (phone.length() == 15 && phone.right(13).startsWith('52')) //005211234567890, remove 00
            return phone.right(13);
        
        else
            return null; 
    }
    
    private static String formatLocale_US(String phone){
        
        if (phone.length() == 11 && phone.startsWith('1')) // 
            return phone;
        
        if (phone.length() == 13 && phone.right(11).startsWith('1')) //005211234567890, remove 00
            return phone.right(11);
        
        else
            return null;
    }
    
    private static String formatLocale_PE(String phone){
                
        if (phone.length() == 11 && (phone.startsWith('51') || phone.indexOf('519') == 0) ) //51912345678
            return phone;
        
        if (phone.length() == 13 && phone.right(11).startsWith('51')) //0051912345678, remove 00
            return phone.right(11);        
        
        else
            return null;
    }
    
    private static String formatLocale_ES(String phone){
                
        if (phone.length() == 11 && (phone.startsWith('34') || (phone.indexOf('346') == 0))) //34624455504
            return phone;
        
        if (phone.length() == 13 && phone.right(11).startsWith('34')) //0034624455504, remove 00
            return phone.right(11);        
        
        else
            return null;
    }

}