% READ_FORCE Reads the force information stored in a finger (or thumb)
%   calibration image and returns the corresponding force/torque vector.
% 
% f = read_force(imgIn,is_thumb) reads the force information stored in the
%     calibration image imgIn and returns the force 6-vector f.  is_thumb
%     is an optional parameter which, if true, indicates that the image is
%     a thumb calibration image and, if false, indicates a finger
%     calibration image.  The default is false, a finger calibration image.
%     
%     For all calibration images, the force vector is stored in the first
%     pixel (1,1), while the torque vector is stored in the seconed pixel
%     (1,2).  The (R,G,B) coordinates correspond to the (X,Y,Z)
%     coordinates.  The mapping is such that 0-255 correspond to the range
%     of force that is desired for a good calibration.  Since shear forces
%     X and Y are calibrated over ranges of -5 to +5 N, the 0-255 corresponds
%     to -6 to +6 N.  The normal force Z is calibrated over a range of 0 to
%     10 N, and so the 0-255 range corresponds to -1 to 11 N.
%     
%     For the thumb calibration images, the data is stored using the same
%     encoding scheme.  However, the thumb is calibrated in a frame rotated
%     90 degrees about the negative y-axis.  Thus, positive z in the thumb
%     frame is negative x in the finger frame, while positive x in the
%     thumb frame is positive z in the finger frame.  Since the x-direction
%     range does not accommodate the full 10 N range, this results in the
%     force appearing to "wrap around" once it reaches +6 N.  The
%     z-direction force behaves similarly once it reaches -1 N.  Thus, it
%     is necessary to modify the data as done in the code.  This removes
%     the need to run a separate program or write different code on the
%     Maglev computer to collect calibration images for the thumb and the
%     fingers.
%     
%     The torques are not being used as of this writing (11 Aug 2010) and
%     so the range is set to an arbitrary number (-10 to +15.5 N-m).  The
%     torques are not meaningless but may have wrapped around as described
%     in the thumb section above.  When we begin to calibrate torques, it
%     may become evident that we have not been accurately monitoring this
%     wrap-around since our range may be too small.
% 
% imgIn    = Image matrix (m-by-n-by-3) with finger data.
% is_thumb = (optional) Boolean value indicating whether this picture is a
%            thumb or a finger image.  Defaults to finger.
% f        = 6-by-1 vector with 3 values of force (Fx,Fy,Fz) and 3 values
%            of torque (Tx,Ty,Tz).
% 

function force = read_force(imgIn, is_thumb)

    % Verify input arguments/handle optional input
    if (nargin() == 1)
        is_thumb = false;
    elseif (nargin() ~= 2)
        error('Must have 1 or 2 input arguments!');
    end
    
    % Preallocate output
    f0 = zeros(1,6);
    force = zeros(1,6);
    
    % Read force from the image
    f0(1) = imgIn(1,1,1);
    f0(2) = imgIn(1,1,2);
    f0(3) = imgIn(1,1,3);
    f0(4) = imgIn(1,2,1);
    f0(5) = imgIn(1,2,2);
    f0(6) = imgIn(1,2,3);
    
    % Convert the force
    force(1) = (double(f0(1)))/21.25-6;
    force(2) = (double(f0(2)))/21.25-6;
    force(3) = 1-(double(f0(3)))/21.25;
    force(4) = (double(f0(4))/0.6375) - 200;
    force(5) = (double(f0(5))/0.6375) - 200;
    force(6) = (double(f0(6))/0.6375) - 200;
    
    % Rearrange thumb data
    if (is_thumb)
        if (force(1) < -1)
            force(1) = force(1) + 12;
        end
        if (force(3) < -6)
            force(3) = force(3) + 12;
        end
    end

end % function
