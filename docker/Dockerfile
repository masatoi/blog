FROM docker pull fukamachi/sbcl:2.5.1-alpine as base
COPY . /app
RUN qlot install
RUN qlot exec ros build roswell/yubin-server.ros
EXPOSE 5000
ENTRYPOINT ["qlot", "exec"]
CMD ["roswell/yubin-server"]
