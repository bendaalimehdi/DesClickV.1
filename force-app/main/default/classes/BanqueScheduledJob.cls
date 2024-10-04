global class BanqueScheduledJob implements Schedulable {
  global void execute(SchedulableContext sc) {
    BanqueBatchUpdate batch = new BanqueBatchUpdate();
    Database.executeBatch(batch);
  }
}
