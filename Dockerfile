FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /opt

# Copy the script into the container at /opt
COPY merge_cnv_files.py /opt/
RUN chmod +x /opt/merge_cnv_files.py

# Install 
RUN python3 -m pip install --upgrade pip
RUN pip install pandas 

# Command to run the script
CMD ["python3","/opt/merge_cnv_files.py"]
