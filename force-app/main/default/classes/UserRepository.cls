public class UserRepository extends AbstractRepository {
    public User findById(String recordId) {
        List<User> records = findById(new List<String>{recordId});
        return records.isEmpty() ? null : records[0];
    }

    public List<User> findById(List<String> recordIds) {
        return Database.query(getBaseQuery() +
                              ' WHERE Id IN :recordIds');
    }

    public List<User> findByGroupName_WorkingInDay(String groupName, String workingDay) {
        return Database.query(getBaseQuery() +
                              ' WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = :groupName) ' +
                              ' AND WorkSchedule__c INCLUDES (:workingDay) ' +
                              ' AND IsActive = true ' +
                              ' ORDER BY DistributionPercentage__c DESC, Id ASC');
    }

    public List<User> findByWorkingInDay(String workingDay) {
        return Database.query(getBaseQuery() +
                              ' WHERE WorkSchedule__c INCLUDES (:workingDay) ' +
                              ' AND IsActive = true ' +
                              ' ORDER BY Id');
    }

    public List<User> findByPartOfEmail(String emailFirstPart) {
        return Database.query(getBaseQuery() +
                              ' WHERE Email LIKE :emailFirstPart ' +
                              ' AND IsActive = true');
    }

    public List<User> findByProfileName(Set<String> profiles) {
        return Database.query(getBaseQuery() +
                              ' WHERE Profile.Name IN :profiles');
    }

    private String getBaseQuery() {
        return 'SELECT Id, Name, Email, IsActive, Profile.Name, UserRole.Name, UserType, WorkSchedule__c, DistributionPercentage__c ' +
               'FROM User';
    }
}