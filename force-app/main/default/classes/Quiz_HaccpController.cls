public with sharing class Quiz_HaccpController {
  public String opportunityId { get; set; }
  public String contactId { get; set; }
  public String contactFirstName { get; set; }
  public String contactLastName { get; set; }
  public String contactSalutation { get; set; }

  public Quiz_HaccpController(ApexPages.StandardController controller) {
    this.opportunityId = controller.getId();
    this.contactId = ApexPages.currentPage().getParameters().get('contactId');

    if (this.contactId != null) {
      Contact contact = [
        SELECT FirstName, LastName, Salutation
        FROM Contact
        WHERE Id = :this.contactId
        LIMIT 1
      ];
      this.contactFirstName = contact.FirstName;
      this.contactLastName = contact.LastName;
      this.contactSalutation = contact.Salutation;
    }
  }
}
