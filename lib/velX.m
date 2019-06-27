function R = velX(theta)

    R = [0 0 0;
        0 -sin(theta) -cos(theta);
        0 cos(theta) -sin(theta)];

end % velX
