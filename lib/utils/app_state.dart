/// 앱 전역 상태 관리 클래스
class AppState {
  // 현재 선택된 학과 정보
  static String? currentDepartmentName;
  static Map<String, dynamic>? currentDepartmentInfo;
  
  // 현재 선택된 식단 상세 정보
  static Map<String, dynamic>? currentMealDetail;
  static List<String>? currentMealImageUrls;
  static String? currentMealCafeteriaName;
  
  // 학과 정보 설정
  static void setCurrentDepartment(String departmentName, Map<String, dynamic> departmentInfo) {
    currentDepartmentName = departmentName;
    currentDepartmentInfo = departmentInfo;
  }
  
  // 학과 정보 초기화
  static void clearCurrentDepartment() {
    currentDepartmentName = null;
    currentDepartmentInfo = null;
  }
  
  // 현재 학과 정보가 있는지 확인
  static bool hasCurrentDepartment() {
    return currentDepartmentName != null && currentDepartmentInfo != null;
  }
  
  // 식단 상세 정보 설정
  static void setCurrentMealDetail(Map<String, dynamic> detail, List<String> imageUrls, String cafeteriaName) {
    currentMealDetail = detail;
    currentMealImageUrls = imageUrls;
    currentMealCafeteriaName = cafeteriaName;
  }
  
  // 식단 상세 정보 초기화
  static void clearCurrentMealDetail() {
    currentMealDetail = null;
    currentMealImageUrls = null;
    currentMealCafeteriaName = null;
  }
  
  // 현재 식단 상세 정보가 있는지 확인
  static bool hasCurrentMealDetail() {
    return currentMealDetail != null && currentMealImageUrls != null && currentMealCafeteriaName != null;
  }
}
