module Api
  class SnapshotsController < ApplicationController
    # GET /api/snapshots
    # GET /api/snapshots/:id
    # Gets all snapshots or a specific snapshot
    #
    # Parameters:
    #   id (integer): id of the snapshot to retrieve
    #
    # Returns:
    #   { data: [snapshot1, snapshot2, ...] }
    #   or
    #   { data: snapshot }
    def index
      if params[:id]
        @snapshots = Snapshot.find(params[:id])
      else
        @snapshots = Snapshot.all
      end
      render json: { data: @snapshots }
    end

    # POST /api/snapshots
    # Creates a new snapshot
    #
    # Parameters:
    #   name (string): name of the snapshot
    #   top_image (string): base64 encoded top image
    #   front_image (string): base64 encoded front image
    #   user_id (integer): user ID the snapshot belongs to
    #   notes (string): notes about the snapshot
    #
    # Returns:
    #   { id: integer, name: string, user_id: integer, top_image: string, front_image: string, notes: string }
    #   or
    #   { errors: { <field_name>: <error_message> } }
    #
    # The top_image and front_image are saved as PNG files with the timestamp on
    # the server as the filename. 
    def create
      if params[:name]
        t = Time.now
        filenameTop = t.strftime("%Y%m%d%H%M%S")  + "_top_image.png"
        filenameFront = t.strftime("%Y%m%d%H%M%S")  + "_front_image.png"
        directory = "#{Rails.root}/public/snapshots/"

        if File.exist?(File.join(directory, filenameTop)) || File.exist?(File.join(directory, filenameFront))
          render json: { errors: "Image already exists" }, status: :unprocessable_entity
        else
          File.open(File.join(directory, filenameTop), 'w+', :encoding => 'binary') do |f|
            f.write(Base64.decode64(params[:top_image]))
          end
          File.open(File.join(directory, filenameFront), 'w+', :encoding => 'binary') do |f|
            f.write(Base64.decode64(params[:front_image]))
          end
          params[:top_image] = filenameTop
          params[:front_image] = filenameFront
          params[:name] = t.strftime("%B %d, %Y")
          snapshot = Snapshot.new(snapshot_params)
          if snapshot.save
            render json: { id: snapshot.id, name: snapshot.name }, status: :created
          else
            render json: { errors: snapshot_params }, status: :unprocessable_entity
          end
        end
      else
        render json: { errors: params }, status: :unprocessable_entity
      end
    end

    # PUT /api/snapshots/:id
    # Updates an existing snapshot
    #
    # Parameters:
    #   name (string): name of the snapshot
    #   top_image (string): base64 encoded top image
    #   front_image (string): base64 encoded front image
    #   user_id (integer): user ID the snapshot belongs to
    #   notes (string): notes about the snapshot
    #
    # Returns:
    #   { id: integer, name: string, user_id: integer, top_image: string, front_image: string, notes: string }
    #   or
    #   { errors: { <field_name>: <error_message> } }
    #
    def update
      snapshot = Snapshot.find(params[:id])
      if snapshot[:top_image] != params[:top_image]
        t = Time.now
        filenameTop = t.strftime("%Y%m%d%H%M%S")  + "_top_image.png"
        directory = "#{Rails.root}/public/snapshots/"
        File.open(File.join(directory, filenameTop), 'w+', :encoding => 'binary') do |f|
          f.write(Base64.decode64(params[:top_image]))
        end
        params[:top_image] = filenameTop
      end
      if snapshot[:front_image] != params[:front_image]
        t = Time.now
        filenameFront = t.strftime("%Y%m%d%H%M%S")  + "_front_image.png"
        directory = "#{Rails.root}/public/snapshots/"
        File.open(File.join(directory, filenameFront), 'w+', :encoding => 'binary') do |f|
          f.write(Base64.decode64(params[:front_image]))
        end
        params[:front_image] = filenameFront
      end
      if snapshot.update(snapshot_params)
        render json: { id: snapshot.id, name: snapshot.name, user_id: snapshot.user_id, top_image: snapshot.top_image, front_image: snapshot.front_image, notes: snapshot.notes }, status: :ok
      else
        render json: { errors: snapshot.errors }, status: :unprocessable_entity
      end
    end

    # DELETE /api/snapshots/:id
    # Deletes the snapshot with the given :id
    #
    # Returns:
    #   { id: integer }
    #   or
    #   { errors: { <field_name>: <error_message> } }
    #
    def destroy
      snapshot = Snapshot.find(params[:id])
      snapshot.destroy
      render json: { id: snapshot.id }, status: :ok
    end

    private

    def snapshot_params
      params.permit(:name, :top_image, :front_image, :user_id, :notes)
    end
  end
end


