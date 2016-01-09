require 'spec_helper'
require 'yt/models/video_group'

describe Yt::VideoGroup, :partner do
  subject(:video_group) { Yt::VideoGroup.new id: id, auth: $content_owner }

  context 'given a video-group', :partner do
    context 'managed by the authenticated Content Owner' do
      let(:id) { ENV['YT_TEST_PARTNER_VIDEO_GROUP_ID'] }

      specify 'the title can be retrieved' do
        expect(video_group.title).to be_a(String)
        expect(video_group.title).not_to be_empty
      end

      specify 'the number of videos in the group can be retrieved' do
        expect(video_group.item_count).to be_an(Integer)
        expect(video_group.item_count).not_to be_zero
      end

      describe 'multiple reports can be retrieved at once' do
        metrics = {views: Integer, uniques: Integer,
          estimated_minutes_watched: Integer, comments: Integer, likes: Integer,
          dislikes: Integer, shares: Integer, subscribers_gained: Integer,
          subscribers_lost: Integer, favorites_added: Integer,
          videos_added_to_playlists: Integer, videos_removed_from_playlists: Integer,
          favorites_removed: Integer, average_view_duration: Integer,
          average_view_percentage: Float, annotation_clicks: Integer,
          annotation_click_through_rate: Float,
          annotation_close_rate: Float, earnings: Float, impressions: Integer,
          monetized_playbacks: Integer}

        specify 'by day, and are chronologically sorted' do
          range = {since: 5.days.ago.to_date, until: 3.days.ago.to_date}
          result = video_group.reports range.merge(only: metrics, by: :day)
          metrics.each do |metric, type|
            expect(result[metric].keys).to all(be_a Date)
            expect(result[metric].values).to all(be_a type)
            expect(result[metric].keys.sort).to eq result[metric].keys
          end
        end

        # NOTE: all the other filters also apply, not tested for brevity
      end

      describe 'viewer_percentage can be grouped by age group' do
        let(:range) { {since: 1.year.ago.to_date, until: 1.week.ago.to_date} }
        let(:keys) { range.values }

        specify 'with the :by option set to :age_group' do
          viewer_percentage = video_group.viewer_percentage range.merge by: :age_group
          expect(viewer_percentage.keys - %w(65- 35-44 45-54 13-17 25-34 55-64 18-24)).to be_empty
          expect(viewer_percentage.values).to all(be_instance_of Float)
        end
      end
    end

    context 'not managed by the authenticated Content Owner' do
      let(:id) { 'ABExJp9gAAA' }

      specify 'views cannot be retrieved' do
        expect{video_group.views}.to raise_error Yt::Error
      end
    end
  end
end