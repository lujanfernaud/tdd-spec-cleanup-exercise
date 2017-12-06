require "rails_helper"

RSpec.describe Invitation do
  describe "callbacks" do
    describe "after_save" do
      context "with valid data" do
        it "invites the user" do
          invitation = invitation_with_team_and_user

          invitation.save

          expect(invitation.user).to be_invited
        end
      end

      context "with invalid data" do
        it "does not save the invitation" do
          invitation = invitation_without_team

          invitation.save

          expect(invitation).not_to be_valid
          expect(invitation).to be_new_record
        end

        it "does not mark the user as invited" do
          invitation = invitation_without_team

          invitation.save

          expect(invitation.user).not_to be_invited
        end
      end
    end
  end

  describe "#event_log_statement" do
    context "when the record is saved" do
      it "include the name of the team" do
        invitation = invitation_with_team "A fine team"

        invitation.save

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("A fine team")
      end

      it "include the email of the invitee" do
        invitation = invitation_with_user_email "rookie@example.com"

        invitation.save

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("rookie@example.com")
      end
    end

    context "when the record is not saved but valid" do
      it "includes the name of the team" do
        invitation = invitation_with_team "A fine team"

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("A fine team")
      end

      it "includes the email of the invitee" do
        invitation = invitation_with_user_email "rookie@example.com"

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("rookie@example.com")
      end

      it "includes the word 'PENDING'" do
        invitation = invitation_with_team_and_user

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("PENDING")
      end
    end

    context "when the record is not saved and not valid" do
      it "includes INVALID" do
        invitation = invitation_without_user

        log_statement = invitation.event_log_statement

        expect(log_statement).to include("INVALID")
      end
    end
  end

  def invitation_with_team_and_user
    team     = create_team "A fine team"
    new_user = create(:user, email: "rookie@example.com")
    build(:invitation, team: team, user: new_user)
  end

  def invitation_without_team
    new_user = create(:user, email: "rookie@example.com")
    build(:invitation, team: nil, user: new_user)
  end

  def invitation_without_user
    team = create_team "A fine team"
    build(:invitation, team: team, user: nil)
  end

  def invitation_with_team(team_name)
    team     = create_team team_name
    new_user = create(:user, email: "rookie@example.com")
    build(:invitation, team: team, user: new_user)
  end

  def invitation_with_user_email(user_email)
    team     = create_team "A fine team"
    new_user = create(:user, email: user_email)
    build(:invitation, team: team, user: new_user)
  end

  def create_team(team_name)
    team = create(:team, name: team_name)
    assign_team_owner(team)
    team
  end

  def assign_team_owner(team)
    team_owner = create(:user)
    team.update!(owner: team_owner)
    team_owner.update!(team: team)
  end
end
